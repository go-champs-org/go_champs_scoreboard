defmodule GoChampsScoreboard.Sports.Basketball.GameStateTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.GameState
  alias GoChampsScoreboard.Games.Models.GameState, as: GameStateModel
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Events.GameSnapshot

  import GoChampsScoreboard.GameStateFixtures

  describe "map_from_snapshot/2" do
    test "updates only players' state and valid stats_values from snapshot" do
      # Create original game state with some players
      original_player = %PlayerState{
        id: "player-1",
        name: "Original Player",
        state: :bench,
        stats_values: %{
          "points" => 10,
          "assists" => 5,
          "field_goals_made" => 3,
          # This should not be updated from snapshot
          "invalid_stat" => 999
        }
      }

      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | players: [original_player]
          }
      }

      # Create snapshot with updated player data
      snapshot_player = %PlayerState{
        id: "player-1",
        name: "Snapshot Player",
        state: :playing,
        stats_values: %{
          # calculated - should update
          "points" => 25,
          # manual - should update
          "assists" => 8,
          # manual - should update
          "field_goals_made" => 10,
          # invalid - should not update
          "invalid_stat" => 777
        }
      }

      snapshot_game_state = %GameStateModel{
        original_game_state
        | clock_state: %GameClockState{
            original_game_state.clock_state
            | # This should NOT be updated
              time: 300,
              period: 2,
              state: :running
          },
          home_team: %TeamState{
            original_game_state.home_team
            | players: [snapshot_player]
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Clock state should remain unchanged
      assert result.clock_state.time == original_game_state.clock_state.time
      assert result.clock_state.period == original_game_state.clock_state.period
      assert result.clock_state.state == original_game_state.clock_state.state

      # Game ID should remain unchanged
      assert result.id == original_game_state.id

      # Player state should be updated
      updated_player = List.first(result.home_team.players)
      assert updated_player.state == :playing

      # Valid stats should be updated
      assert updated_player.stats_values["points"] == 25
      assert updated_player.stats_values["assists"] == 8
      assert updated_player.stats_values["field_goals_made"] == 10

      # Invalid stats should keep original value
      assert updated_player.stats_values["invalid_stat"] == 999
    end

    test "handles players not present in snapshot" do
      original_player = %PlayerState{
        id: "player-not-in-snapshot",
        name: "Original Player",
        state: :bench,
        stats_values: %{"points" => 10}
      }

      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | players: [original_player]
          }
      }

      # Snapshot has no matching player
      snapshot_game_state = %GameStateModel{
        original_game_state
        | home_team: %TeamState{
            original_game_state.home_team
            | # No players in snapshot
              players: []
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Player should remain unchanged since not found in snapshot
      updated_player = List.first(result.home_team.players)
      assert updated_player.id == "player-not-in-snapshot"
      assert updated_player.state == :bench
      assert updated_player.stats_values["points"] == 10
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

    test "preserves game state fields and only updates player data when restoring from snapshot" do
      original_game_state = basketball_game_state_fixture()

      # Create a comprehensive different game state with different fields
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
          stats_values: %{"points" => 95, "fouls_technical" => 3},
          # No players to update
          players: []
        },
        away_team: %TeamState{
          name: "Away Team Restored",
          stats_values: %{"points" => 87, "fouls_technical" => 2},
          # No players to update
          players: []
        }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Verify original fields are preserved (not updated from snapshot)
      assert result.id == original_game_state.id
      assert result.sport_id == original_game_state.sport_id
      assert result.clock_state.time == original_game_state.clock_state.time
      assert result.clock_state.period == original_game_state.clock_state.period
      assert result.clock_state.state == original_game_state.clock_state.state
      assert result.home_team.name == original_game_state.home_team.name
      assert result.away_team.name == original_game_state.away_team.name

      # Team stats should be updated from snapshot for valid keys
      # Updated from snapshot
      assert result.home_team.stats_values["fouls_technical"] == 3
      # Preserved from original (no change in snapshot)
      assert result.home_team.stats_values["timeouts"] == 0
      # Updated from snapshot
      assert result.away_team.stats_values["fouls_technical"] == 2
    end

    test "updates total_player_stats correctly from snapshot with valid stat keys only" do
      # Create original game state with players that have total_player_stats
      original_player1 = %PlayerState{
        id: "player-1",
        name: "Player 1",
        state: :playing,
        stats_values: %{
          "points" => 10,
          "assists" => 5,
          "field_goals_made" => 3,
          "invalid_stat" => 100
        }
      }

      original_player2 = %PlayerState{
        id: "player-2",
        name: "Player 2",
        state: :bench,
        stats_values: %{
          "points" => 8,
          "assists" => 3,
          "field_goals_made" => 2,
          "invalid_stat" => 50
        }
      }

      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | players: [original_player1, original_player2],
              total_player_stats: %{
                "points" => 18,
                "assists" => 8,
                "field_goals_made" => 5,
                "invalid_stat" => 150
              }
          }
      }

      # Create snapshot with updated player stats
      snapshot_player1 = %PlayerState{
        id: "player-1",
        name: "Player 1",
        state: :playing,
        stats_values: %{
          # calculated - should update
          "points" => 25,
          # manual - should update
          "assists" => 12,
          # manual - should update
          "field_goals_made" => 8,
          # invalid - should not update
          "invalid_stat" => 200
        }
      }

      snapshot_player2 = %PlayerState{
        id: "player-2",
        name: "Player 2",
        state: :bench,
        stats_values: %{
          # calculated - should update
          "points" => 15,
          # manual - should update
          "assists" => 7,
          # manual - should update
          "field_goals_made" => 5,
          # invalid - should not update
          "invalid_stat" => 300
        }
      }

      snapshot_game_state = %GameStateModel{
        original_game_state
        | home_team: %TeamState{
            original_game_state.home_team
            | players: [snapshot_player1, snapshot_player2],
              total_player_stats: %{
                "points" => 40,
                "assists" => 19,
                "field_goals_made" => 13,
                "invalid_stat" => 500
              }
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Verify total_player_stats is correctly updated with only valid stats
      assert result.home_team.total_player_stats["points"] == 40
      assert result.home_team.total_player_stats["assists"] == 19
      assert result.home_team.total_player_stats["field_goals_made"] == 13

      # Invalid stat should remain from original (not updated from snapshot, but preserved)
      # Original value, not 500 from snapshot
      assert result.home_team.total_player_stats["invalid_stat"] == 150

      updated_player1 = Enum.find(result.home_team.players, &(&1.id == "player-1"))
      updated_player2 = Enum.find(result.home_team.players, &(&1.id == "player-2"))

      assert updated_player1.stats_values["points"] == 25
      assert updated_player1.stats_values["assists"] == 12
      assert updated_player1.stats_values["field_goals_made"] == 8
      # Should keep original
      assert updated_player1.stats_values["invalid_stat"] == 100

      assert updated_player2.stats_values["points"] == 15
      assert updated_player2.stats_values["assists"] == 7
      assert updated_player2.stats_values["field_goals_made"] == 5
      # Should keep original
      assert updated_player2.stats_values["invalid_stat"] == 50
    end

    test "updates team stats correctly from snapshot with valid stat keys only" do
      # Create original game state with team stats
      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | stats_values: %{
                "timeouts" => 3,
                "fouls_technical" => 1,
                "invalid_team_stat" => 99
              }
          }
      }

      # Create snapshot with updated team stats
      snapshot_game_state = %GameStateModel{
        original_game_state
        | home_team: %TeamState{
            original_game_state.home_team
            | stats_values: %{
                # manual - should update
                "timeouts" => 5,
                # manual - should update
                "fouls_technical" => 3,
                # invalid - should not update
                "invalid_team_stat" => 200
              }
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Verify team stats are correctly updated with only valid stats
      # Updated from snapshot
      assert result.home_team.stats_values["timeouts"] == 5
      # Updated from snapshot
      assert result.home_team.stats_values["fouls_technical"] == 3

      # Invalid team stat should remain from original (not updated from snapshot, but preserved)
      # Original value, not 200 from snapshot
      assert result.home_team.stats_values["invalid_team_stat"] == 99
    end
  end
end
