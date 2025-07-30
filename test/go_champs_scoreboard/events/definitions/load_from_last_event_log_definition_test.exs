defmodule GoChampsScoreboard.Events.Definitions.LoadFromLastEventLogDefinitionTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Events.Definitions.LoadFromLastEventLogDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures

  describe "key/0" do
    test "returns the correct key" do
      assert LoadFromLastEventLogDefinition.key() == "load-from-last-event-log"
    end
  end

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} = LoadFromLastEventLogDefinition.validate(game_state, %{})
    end
  end

  describe "create/4" do
    test "returns event with persistable: false" do
      event = LoadFromLastEventLogDefinition.create("some-game-id", 600, 1, %{})

      assert %Event{
               key: "load-from-last-event-log",
               game_id: "some-game-id",
               clock_state_time_at: 600,
               clock_state_period_at: 1
             } = event

      assert event.meta.persistable == false
    end
  end

  describe "stream_config/0" do
    test "returns a valid stream config" do
      result = LoadFromLastEventLogDefinition.stream_config()

      assert %StreamConfig{} = result
    end
  end

  describe "handle/2" do
    test "returns the same game state when no event log exists" do
      game_state = game_state_fixture()
      event = %Event{key: "load-from-last-event-log", game_id: game_state.id}

      result = LoadFromLastEventLogDefinition.handle(game_state, event)

      assert result == game_state
    end

    test "returns game state from snapshot when event log with snapshot exists for basketball" do
      original_game_state = basketball_game_state_fixture()
      event = %Event{key: "load-from-last-event-log", game_id: original_game_state.id}

      # Create a modified game state
      modified_game_state = %GameState{
        original_game_state
        | clock_state: %GameClockState{
            original_game_state.clock_state
            | time: 300,
              period: 2,
              state: :running
          }
      }

      # Create an event and persist it with the modified state
      test_event =
        GoChampsScoreboard.Events.Definitions.StartGameDefinition.create(
          original_game_state.id,
          600,
          1,
          %{}
        )

      {:ok, _event_log} = EventLogs.persist(test_event, modified_game_state)

      result = LoadFromLastEventLogDefinition.handle(original_game_state, event)

      # Should restore the modified state from the snapshot
      assert result.clock_state.time == 300
      assert result.clock_state.period == 2
      assert result.clock_state.state == :running
    end
  end
end
