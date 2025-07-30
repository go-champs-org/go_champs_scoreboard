defmodule GoChampsScoreboard.Sports.Basketball.GameStateTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.GameState
  alias GoChampsScoreboard.Games.Models.GameState, as: GameStateModel
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Events.GameSnapshot

  import GoChampsScoreboard.GameStateFixtures

  describe "map_from_snapshot/2" do
    test "returns restored game state when snapshot contains a valid GameState" do
      original_game_state = basketball_game_state_fixture()

      # Create a different game state that would be in the snapshot
      snapshot_game_state = %GameStateModel{
        original_game_state
        | clock_state: %GameClockState{
            original_game_state.clock_state
            | time: 300,
              period: 2,
              state: :running
          },
          home_team: %TeamState{
            original_game_state.home_team
            | stats_values: Map.put(original_game_state.home_team.stats_values, "points", 25)
          }
      }

      # Create a mock snapshot structure
      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      assert result.clock_state.time == 300
      assert result.clock_state.period == 2
      assert result.clock_state.state == :running
      assert result.home_team.stats_values["points"] == 25
      assert result.id == snapshot_game_state.id
    end

    test "returns original game state when snapshot state is not a valid GameState" do
      original_game_state = basketball_game_state_fixture()

      # Create a mock snapshot with invalid state
      mock_snapshot = %GameSnapshot{state: %{invalid: "data"}}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      assert result == original_game_state
    end

    test "returns original game state when snapshot state is nil" do
      original_game_state = basketball_game_state_fixture()

      # Create a mock snapshot with nil state
      mock_snapshot = %GameSnapshot{state: nil}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      assert result == original_game_state
    end

    test "returns original game state when snapshot state is a string or primitive" do
      original_game_state = basketball_game_state_fixture()

      # Create a mock snapshot with string state
      mock_snapshot = %GameSnapshot{state: "invalid_state"}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      assert result == original_game_state
    end

    test "preserves all game state fields when restoring from snapshot" do
      original_game_state = basketball_game_state_fixture()

      # Create a comprehensive different game state
      snapshot_game_state = %GameStateModel{
        id: "different-id",
        sport_id: "basketball",
        clock_state: %GameClockState{
          time: 180,
          period: 4,
          state: :finished,
          initial_period_time: 720,
          initial_extra_period_time: 300,
          started_at: DateTime.utc_now(),
          finished_at: DateTime.utc_now()
        },
        home_team: %TeamState{
          name: "Home Team Restored",
          stats_values: %{"points" => 95, "fouls_technical" => 3}
        },
        away_team: %TeamState{
          name: "Away Team Restored",
          stats_values: %{"points" => 87, "fouls_technical" => 2}
        }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Verify all fields are restored
      assert result.id == "different-id"
      assert result.sport_id == "basketball"
      assert result.clock_state.time == 180
      assert result.clock_state.period == 4
      assert result.clock_state.state == :finished
      assert result.home_team.name == "Home Team Restored"
      assert result.home_team.stats_values["points"] == 95
      assert result.away_team.name == "Away Team Restored"
      assert result.away_team.stats_values["points"] == 87
    end
  end
end
