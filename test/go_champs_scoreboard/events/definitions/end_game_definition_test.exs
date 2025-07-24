defmodule GoChampsScoreboard.Events.Definitions.EndGameDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.EndGameDefinition
  alias GoChampsScoreboard.Games.Models.{GameState}

  import GoChampsScoreboard.GameStateFixtures

  describe "key/0" do
    test "returns the correct key" do
      assert EndGameDefinition.key() == "end-game"
    end
  end

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               EndGameDefinition.validate(game_state, %{})
    end
  end

  describe "create/4" do
    test "returns event" do
      assert %Event{
               key: "end-game",
               game_id: "some-game-id",
               clock_state_time_at: 0,
               clock_state_period_at: 4
             } =
               EndGameDefinition.create("some-game-id", 0, 4, %{})
    end
  end

  describe "handle/2" do
    test "returns updated game state with finished clock state and finished_at timestamp" do
      running_clock_state = %GameClockState{
        time: 0,
        period: 4,
        state: :running,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: DateTime.utc_now(),
        finished_at: nil
      }

      game_state = basketball_game_state_fixture(clock_state: running_clock_state)

      result = EndGameDefinition.handle(game_state, nil)

      assert result.clock_state.period == 4
      assert result.clock_state.time == 0
      assert result.clock_state.state == :finished
      assert result.clock_state.started_at != nil
      assert result.clock_state.finished_at != nil
      assert DateTime.diff(DateTime.utc_now(), result.clock_state.finished_at, :second) < 1
    end

    test "ends game from paused state" do
      paused_clock_state = %GameClockState{
        time: 120,
        period: 3,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: DateTime.utc_now(),
        finished_at: nil
      }

      game_state = basketball_game_state_fixture(clock_state: paused_clock_state)

      result = EndGameDefinition.handle(game_state, nil)

      assert result.clock_state.period == 3
      assert result.clock_state.time == 120
      assert result.clock_state.state == :finished
      assert result.clock_state.started_at != nil
      assert result.clock_state.finished_at != nil
      assert DateTime.diff(DateTime.utc_now(), result.clock_state.finished_at, :second) < 1
    end

    test "ends game from stopped state" do
      stopped_clock_state = %GameClockState{
        time: 300,
        period: 2,
        state: :stopped,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: DateTime.utc_now(),
        finished_at: nil
      }

      game_state = basketball_game_state_fixture(clock_state: stopped_clock_state)

      result = EndGameDefinition.handle(game_state, nil)

      assert result.clock_state.period == 2
      assert result.clock_state.time == 300
      assert result.clock_state.state == :finished
      assert result.clock_state.started_at != nil
      assert result.clock_state.finished_at != nil
      assert DateTime.diff(DateTime.utc_now(), result.clock_state.finished_at, :second) < 1
    end
  end

  describe "stream_config/0" do
    test "returns stream config" do
      config = EndGameDefinition.stream_config()
      assert config != nil
    end
  end
end
