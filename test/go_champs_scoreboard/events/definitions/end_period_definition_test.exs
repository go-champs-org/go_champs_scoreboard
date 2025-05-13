defmodule GoChampsScoreboard.Events.Definitions.EndPeriodDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.EndPeriodDefinition
  alias GoChampsScoreboard.Games.Models.{GameState}

  import GoChampsScoreboard.GameStateFixtures

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               EndPeriodDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "end-period",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               EndPeriodDefinition.create("some-game-id", 10, 1, %{})
    end
  end

  describe "handle/2" do
    test "returns updated game state with next clock state for the sport" do
      end_of_period_clock_state = %GameClockState{
        time: 0,
        period: 1,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      game_state = basketball_game_state_fixture(clock_state: end_of_period_clock_state)

      result =
        EndPeriodDefinition.handle(game_state, nil)

      assert result.clock_state.period == 2
      assert result.clock_state.time == 600
      assert result.clock_state.state == :paused
    end
  end
end
