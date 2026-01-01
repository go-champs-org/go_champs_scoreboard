defmodule GoChampsScoreboard.Sports.Basketball.TeamStateTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Basketball.TeamState
  alias GoChampsScoreboard.Games.Models.TeamState, as: TeamStateModel

  describe "set_walkover/1" do
    test "sets the game_walkover stat and updates calculated stats" do
      initial_team_state = TeamStateModel.new(%{stats: %{}})
      updated_team_state = TeamState.set_walkover(initial_team_state)

      assert Map.get(updated_team_state.stats_values, "game_walkover") == 1
      assert Map.get(updated_team_state.stats_values, "points") == 0
    end
  end

  describe "set_walkover_against/1" do
    test "sets the game_walkover_against stat and updates calculated stats" do
      initial_team_state = TeamStateModel.new(%{stats: %{}})
      updated_team_state = TeamState.set_walkover_against(initial_team_state)

      assert Map.get(updated_team_state.stats_values, "game_walkover_against") == 1
      assert Map.get(updated_team_state.stats_values, "points") == 20
    end
  end
end
