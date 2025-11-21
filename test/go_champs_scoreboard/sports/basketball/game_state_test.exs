defmodule GoChampsScoreboard.Sports.Basketball.GameStateTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.GameState
  alias GoChampsScoreboard.Games.Models.GameState, as: GameStateModel
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.CoachState
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

    test "updates total_coach_stats correctly from snapshot with valid stat keys only" do
      # Create original game state with coaches that have total_coach_stats
      original_coach1 = %CoachState{
        id: "coach-1",
        name: "Head Coach",
        type: :head_coach,
        state: :available,
        stats_values: %{
          "fouls_technical" => 2,
          "fouls_disqualifying" => 1,
          "invalid_stat" => 100
        }
      }

      original_coach2 = %CoachState{
        id: "coach-2",
        name: "Assistant Coach",
        type: :assistant_coach,
        state: :available,
        stats_values: %{
          "fouls_technical" => 1,
          "fouls_disqualifying" => 0,
          "invalid_stat" => 50
        }
      }

      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | coaches: [original_coach1, original_coach2],
              total_coach_stats: %{
                "fouls_technical" => 3,
                "fouls_disqualifying" => 1,
                "invalid_stat" => 150
              }
          }
      }

      # Create snapshot with updated coach stats
      snapshot_coach1 = %CoachState{
        id: "coach-1",
        name: "Head Coach",
        type: :head_coach,
        state: :available,
        stats_values: %{
          # manual - should update
          "fouls_technical" => 4,
          # manual - should update
          "fouls_disqualifying" => 2,
          # invalid - should not update
          "invalid_stat" => 200
        }
      }

      snapshot_coach2 = %CoachState{
        id: "coach-2",
        name: "Assistant Coach",
        type: :assistant_coach,
        state: :available,
        stats_values: %{
          # manual - should update
          "fouls_technical" => 2,
          # manual - should update
          "fouls_disqualifying" => 1,
          # invalid - should not update
          "invalid_stat" => 300
        }
      }

      snapshot_game_state = %GameStateModel{
        original_game_state
        | home_team: %TeamState{
            original_game_state.home_team
            | coaches: [snapshot_coach1, snapshot_coach2],
              total_coach_stats: %{
                "fouls_technical" => 6,
                "fouls_disqualifying" => 3,
                "invalid_stat" => 500
              }
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Verify total_coach_stats is correctly updated with only valid stats
      assert result.home_team.total_coach_stats["fouls_technical"] == 6
      assert result.home_team.total_coach_stats["fouls_disqualifying"] == 3

      # Invalid stat should remain from original (not updated from snapshot, but preserved)
      # Original value, not 500 from snapshot
      assert result.home_team.total_coach_stats["invalid_stat"] == 150

      updated_coach1 = Enum.find(result.home_team.coaches, &(&1.id == "coach-1"))
      updated_coach2 = Enum.find(result.home_team.coaches, &(&1.id == "coach-2"))

      # Coaches now get updated in map_from_snapshot with matching IDs from snapshot
      # Valid stats should be updated from snapshot
      assert updated_coach1.stats_values["fouls_technical"] == 4
      assert updated_coach1.stats_values["fouls_disqualifying"] == 2
      # Should keep original
      assert updated_coach1.stats_values["invalid_stat"] == 100

      assert updated_coach2.stats_values["fouls_technical"] == 2
      assert updated_coach2.stats_values["fouls_disqualifying"] == 1
      # Should keep original
      assert updated_coach2.stats_values["invalid_stat"] == 50
    end

    test "updates coaches' state and valid stats_values from snapshot" do
      # Create original game state with some coaches
      original_coach = %CoachState{
        id: "coach-1",
        name: "Original Coach",
        type: :head_coach,
        state: :available,
        stats_values: %{
          "fouls_technical" => 1,
          "fouls_disqualifying" => 0,
          # This should not be updated from snapshot
          "invalid_stat" => 999
        }
      }

      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | coaches: [original_coach]
          }
      }

      # Create snapshot with updated coach data
      snapshot_coach = %CoachState{
        id: "coach-1",
        name: "Snapshot Coach",
        type: :assistant_coach,
        state: :not_available,
        stats_values: %{
          # manual - should update
          "fouls_technical" => 3,
          # manual - should update
          "fouls_disqualifying" => 1,
          # invalid - should not update
          "invalid_stat" => 777
        }
      }

      snapshot_game_state = %GameStateModel{
        original_game_state
        | home_team: %TeamState{
            original_game_state.home_team
            | coaches: [snapshot_coach]
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Coach state should be updated
      updated_coach = List.first(result.home_team.coaches)
      assert updated_coach.state == :not_available

      # Valid stats should be updated
      assert updated_coach.stats_values["fouls_technical"] == 3
      assert updated_coach.stats_values["fouls_disqualifying"] == 1

      # Invalid stats should keep original value
      assert updated_coach.stats_values["invalid_stat"] == 999

      # Note: name and type are not updated by snapshot mapping (only state and stats_values)
      assert updated_coach.name == "Original Coach"
      assert updated_coach.type == :head_coach
    end

    test "handles coaches not present in snapshot" do
      original_coach = %CoachState{
        id: "coach-not-in-snapshot",
        name: "Original Coach",
        type: :head_coach,
        state: :available,
        stats_values: %{"fouls_technical" => 2}
      }

      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | coaches: [original_coach]
          }
      }

      # Snapshot has no matching coach
      snapshot_game_state = %GameStateModel{
        original_game_state
        | home_team: %TeamState{
            original_game_state.home_team
            | # No coaches in snapshot
              coaches: []
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Coach should remain unchanged since not found in snapshot
      updated_coach = List.first(result.home_team.coaches)
      assert updated_coach.id == "coach-not-in-snapshot"
      assert updated_coach.state == :available
      assert updated_coach.stats_values["fouls_technical"] == 2
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

    test "maps period_stats from snapshot" do
      # Create original game state with some period stats
      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: %{
                "1" => %{"timeouts" => 1, "fouls_technical" => 0},
                "2" => %{"timeouts" => 0, "fouls_technical" => 1}
              }
          }
      }

      # Create snapshot with updated period stats
      snapshot_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: %{
                "1" => %{"timeouts" => 2, "fouls_technical" => 1},
                "2" => %{"timeouts" => 1, "fouls_technical" => 0},
                "3" => %{"timeouts" => 0, "fouls_technical" => 2}
              }
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Period stats should be completely replaced from snapshot
      assert result.home_team.period_stats == %{
               "1" => %{"timeouts" => 2, "fouls_technical" => 1},
               "2" => %{"timeouts" => 1, "fouls_technical" => 0},
               "3" => %{"timeouts" => 0, "fouls_technical" => 2}
             }
    end

    test "handles nil period_stats from snapshot gracefully" do
      # Create original game state with some period stats
      original_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: %{
                "1" => %{"timeouts" => 1, "fouls_technical" => 0}
              }
          }
      }

      # Create snapshot with nil period stats
      snapshot_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: nil
          }
      }

      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = GameState.map_from_snapshot(original_game_state, mock_snapshot)

      # Period stats should be set to empty map when snapshot has nil
      assert result.home_team.period_stats == %{}
    end
  end

  describe "copy_all_stats_from_game_state/2" do
    test "copies player stats from source to target game state for matching players" do
      original_player = %PlayerState{
        id: "player-1",
        name: "Original Player",
        state: :playing,
        stats_values: %{
          "points" => 25,
          "assists" => 8,
          "field_goals_made" => 10,
          "rebounds_defensive" => 5
        }
      }

      source_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | players: [original_player]
          }
      }

      # Same ID as original player but different stats
      target_player_same_id = %PlayerState{
        id: "player-1",
        name: "Target Player Same ID",
        state: :bench,
        stats_values: %{
          "points" => 5,
          "assists" => 2,
          "field_goals_made" => 2,
          "rebounds_defensive" => 1
        }
      }

      target_player_different_id = %PlayerState{
        id: "player-2",
        name: "Target Player Different ID",
        state: :available,
        stats_values: %{
          "points" => 15,
          "assists" => 6,
          "field_goals_made" => 6,
          "rebounds_defensive" => 3
        }
      }

      target_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | players: [target_player_same_id, target_player_different_id]
          }
      }

      result = GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)

      assert length(result.home_team.players) == 2

      result_player_1 = Enum.find(result.home_team.players, &(&1.id == "player-1"))
      result_player_2 = Enum.find(result.home_team.players, &(&1.id == "player-2"))

      assert result_player_1.id == "player-1"
      assert result_player_1.name == original_player.name
      assert result_player_1.state == original_player.state
      assert result_player_1.stats_values["points"] == 25
      assert result_player_1.stats_values["assists"] == 8
      assert result_player_1.stats_values["field_goals_made"] == 10
      assert result_player_1.stats_values["rebounds_defensive"] == 5

      assert result_player_2.id == "player-2"
      assert result_player_2.name == target_player_different_id.name
      assert result_player_2.state == target_player_different_id.state
      assert result_player_2.stats_values["points"] == 15
      assert result_player_2.stats_values["assists"] == 6
      assert result_player_2.stats_values["field_goals_made"] == 6
      assert result_player_2.stats_values["rebounds_defensive"] == 3
    end

    test "copies coach stats from source to target game state for matching coaches" do
      original_coach = %CoachState{
        id: "coach-1",
        name: "Original Coach",
        type: :head_coach,
        state: :available,
        stats_values: %{
          "fouls_technical" => 2,
          "fouls_personal" => 1
        }
      }

      source_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | coaches: [original_coach],
              players: []
          }
      }

      # Same ID as original coach but different stats and type
      target_coach_same_id = %CoachState{
        id: "coach-1",
        name: "Target Coach Same ID",
        type: :assistant_coach,
        state: :not_available,
        stats_values: %{
          "fouls_technical" => 0,
          "fouls_personal" => 0
        }
      }

      target_coach_different_id = %CoachState{
        id: "coach-2",
        name: "Target Coach Different ID",
        type: :head_coach,
        state: :available,
        stats_values: %{
          "fouls_technical" => 1,
          "fouls_personal" => 3
        }
      }

      target_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | coaches: [target_coach_same_id, target_coach_different_id],
              players: []
          }
      }

      result = GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)

      assert length(result.home_team.coaches) == 2

      result_coach_1 = Enum.find(result.home_team.coaches, &(&1.id == "coach-1"))
      result_coach_2 = Enum.find(result.home_team.coaches, &(&1.id == "coach-2"))

      assert result_coach_1.id == "coach-1"
      assert result_coach_1.name == original_coach.name
      assert result_coach_1.type == original_coach.type
      assert result_coach_1.state == original_coach.state
      assert result_coach_1.stats_values["fouls_technical"] == 2
      assert result_coach_1.stats_values["fouls_personal"] == 1

      assert result_coach_2.id == "coach-2"
      assert result_coach_2.name == target_coach_different_id.name
      assert result_coach_2.type == target_coach_different_id.type
      assert result_coach_2.state == target_coach_different_id.state
      assert result_coach_2.stats_values["fouls_technical"] == 1
      assert result_coach_2.stats_values["fouls_personal"] == 3
    end

    test "copies team stats from source to target game state" do
      # Create source game state with specific team stats
      source_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | total_player_stats: %{
                "points" => 85,
                "assists" => 22,
                "field_goals_made" => 35
              },
              stats_values: %{
                "timeouts" => 3,
                "fouls_technical" => 2,
                "points" => 85
              },
              # Remove players to focus on team stats
              players: [],
              # Remove coaches to focus on team stats
              coaches: []
          }
      }

      # Create target game state with different team stats
      target_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | total_player_stats: %{
                "points" => 45,
                "assists" => 12,
                "field_goals_made" => 18
              },
              stats_values: %{
                "timeouts" => 5,
                "fouls_technical" => 0,
                "points" => 45
              },
              # Remove players to focus on team stats
              players: [],
              # Remove coaches to focus on team stats
              coaches: []
          }
      }

      result = GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)

      # Assert that team total_player_stats are copied from source
      assert result.home_team.total_player_stats["points"] == 85
      assert result.home_team.total_player_stats["assists"] == 22
      assert result.home_team.total_player_stats["field_goals_made"] == 35

      # Assert that team stats_values are copied from source
      assert result.home_team.stats_values["timeouts"] == 3
      assert result.home_team.stats_values["fouls_technical"] == 2
      assert result.home_team.stats_values["points"] == 85
    end

    test "copies total_coach_stats from source to target game state" do
      # Create source game state with coach stats
      source_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | total_coach_stats: %{
                "fouls_technical" => 4,
                "fouls_disqualifying" => 2,
                "fouls" => 6
              },
              # Remove players to focus on coach stats
              players: [],
              # Remove coaches to focus on team stats
              coaches: []
          }
      }

      # Create target game state with different coach stats
      target_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | total_coach_stats: %{
                "fouls_technical" => 1,
                "fouls_disqualifying" => 0,
                "fouls" => 1
              },
              # Remove players to focus on coach stats
              players: [],
              # Remove coaches to focus on team stats
              coaches: []
          }
      }

      result = GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)

      # Assert that team total_coach_stats are copied from source
      assert result.home_team.total_coach_stats["fouls_technical"] == 4
      assert result.home_team.total_coach_stats["fouls_disqualifying"] == 2
      assert result.home_team.total_coach_stats["fouls"] == 6
    end

    test "copies period_stats from source to target game state" do
      # Create source game state with period stats
      source_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: %{
                "1" => %{"timeouts" => 2, "fouls_technical" => 1},
                "2" => %{"timeouts" => 0, "fouls_technical" => 3},
                "3" => %{"timeouts" => 1, "fouls_technical" => 0}
              }
          }
      }

      # Create target game state with different period stats
      target_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: %{
                "1" => %{"timeouts" => 1, "fouls_technical" => 0}
              }
          }
      }

      result = GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)

      # Period stats should be completely replaced from source
      assert result.home_team.period_stats == %{
               "1" => %{"timeouts" => 2, "fouls_technical" => 1},
               "2" => %{"timeouts" => 0, "fouls_technical" => 3},
               "3" => %{"timeouts" => 1, "fouls_technical" => 0}
             }
    end

    test "handles nil period_stats in source game state" do
      # Create source game state with nil period stats
      source_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: nil
          }
      }

      # Create target game state with some period stats
      target_game_state = %GameStateModel{
        basketball_game_state_fixture()
        | home_team: %TeamState{
            basketball_game_state_fixture().home_team
            | period_stats: %{
                "1" => %{"timeouts" => 1, "fouls_technical" => 0}
              }
          }
      }

      result = GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)

      # Period stats should be set to empty map when source has nil
      assert result.home_team.period_stats == %{}
    end
  end

  describe "protest_game/2" do
    test "updates game state protest with team-id and player-id from payload" do
      game_state = basketball_game_state_fixture()

      event_payload = %{
        "team-type" => "away",
        "player-id" => "away-player-123"
      }

      result = GameState.protest_game(game_state, event_payload)

      assert result.protest.team_type == :away
      assert result.protest.player_id == "away-player-123"
      assert result.protest.state == :protest_filed
    end

    test "updates game state protest with empty strings when payload keys are missing" do
      game_state = basketball_game_state_fixture()

      event_payload = %{}

      result = GameState.protest_game(game_state, event_payload)

      assert result.protest.team_type == :none
      assert result.protest.player_id == ""
      assert result.protest.state == :protest_filed
    end

    test "updates game state protest with home team data" do
      game_state = basketball_game_state_fixture()

      event_payload = %{
        "team-type" => "home",
        "player-id" => "home-player-456"
      }

      result = GameState.protest_game(game_state, event_payload)

      assert result.protest.team_type == :home
      assert result.protest.player_id == "home-player-456"
      assert result.protest.state == :protest_filed
    end

    test "preserves other game state fields when updating protest" do
      game_state = basketball_game_state_fixture()
      original_id = game_state.id
      original_clock_time = game_state.clock_state.time

      event_payload = %{
        "team-type" => "away",
        "player-id" => "player-789"
      }

      result = GameState.protest_game(game_state, event_payload)

      assert result.id == original_id
      assert result.clock_state.time == original_clock_time
      assert result.home_team == game_state.home_team
      assert result.away_team == game_state.away_team
    end
  end
end
