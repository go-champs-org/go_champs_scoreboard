defmodule GoChampsScoreboard.Events.Definitions.StartGameDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.StartGameDefinition
  alias GoChampsScoreboard.Games.Models.{GameState}

  import GoChampsScoreboard.GameStateFixtures

  describe "key/0" do
    test "returns the correct key" do
      assert StartGameDefinition.key() == "start-game"
    end
  end

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               StartGameDefinition.validate(game_state, %{})
    end
  end

  describe "create/4" do
    test "returns event" do
      assert %Event{
               key: "start-game",
               game_id: "some-game-id",
               clock_state_time_at: 600,
               clock_state_period_at: 1
             } =
               StartGameDefinition.create("some-game-id", 600, 1, %{})
    end
  end

  describe "handle/2" do
    test "returns updated game state with running clock state and started_at timestamp" do
      not_started_clock_state = %GameClockState{
        time: 600,
        period: 1,
        state: :not_started,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: nil,
        finished_at: nil
      }

      game_state = basketball_game_state_fixture(clock_state: not_started_clock_state)

      result = StartGameDefinition.handle(game_state, nil)

      assert result.clock_state.period == 1
      assert result.clock_state.time == 600
      assert result.clock_state.state == :running
      assert result.clock_state.started_at != nil
      assert result.clock_state.finished_at == nil
      assert DateTime.diff(DateTime.utc_now(), result.clock_state.started_at, :second) < 1
    end

    test "does not change finished game state" do
      finished_clock_state = %GameClockState{
        time: 0,
        period: 4,
        state: :finished,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: DateTime.utc_now(),
        finished_at: DateTime.utc_now()
      }

      game_state = basketball_game_state_fixture(clock_state: finished_clock_state)

      result = StartGameDefinition.handle(game_state, nil)

      # Should remain unchanged
      assert result.clock_state == finished_clock_state
    end
  end

  describe "stream_config/0" do
    test "returns stream config" do
      config = StartGameDefinition.stream_config()
      assert config != nil
    end
  end
end
