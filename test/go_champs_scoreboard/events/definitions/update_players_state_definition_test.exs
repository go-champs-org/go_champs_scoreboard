defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayersStateDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, PlayerState}
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayersStateDefinition
  alias GoChampsScoreboard.Events.Models.Event

  describe "key/0" do
    test "returns correct key" do
      assert UpdatePlayersStateDefinition.key() == "update-players-state"
    end
  end

  describe "validate/2" do
    setup do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{id: "player-1", state: :playing, stats_values: %{}},
            %PlayerState{id: "player-2", state: :bench, stats_values: %{}}
          ]
        },
        away_team: %TeamState{
          players: [
            %PlayerState{id: "player-3", state: :available, stats_values: %{}}
          ]
        }
      }

      %{game_state: game_state}
    end

    test "returns :ok with valid payload", %{game_state: game_state} do
      payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1", "player-2"],
        "state" => "bench"
      }

      assert {:ok} = UpdatePlayersStateDefinition.validate(game_state, payload)
    end

    test "returns error with invalid team-type" do
      payload = %{
        "team-type" => "invalid",
        "player-ids" => ["player-1"],
        "state" => "bench"
      }

      assert {:error, "Invalid or missing team-type. Must be 'home' or 'away'"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error with missing team-type" do
      payload = %{
        "player-ids" => ["player-1"],
        "state" => "bench"
      }

      assert {:error, "Invalid or missing team-type. Must be 'home' or 'away'"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error with invalid player-ids (not a list)" do
      payload = %{
        "team-type" => "home",
        "player-ids" => "player-1",
        "state" => "bench"
      }

      assert {:error, "Invalid or missing player-ids. Must be a non-empty list of strings"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error with empty player-ids list" do
      payload = %{
        "team-type" => "home",
        "player-ids" => [],
        "state" => "bench"
      }

      assert {:error, "Invalid or missing player-ids. Must be a non-empty list of strings"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error with non-string player-ids" do
      payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1", 123],
        "state" => "bench"
      }

      assert {:error, "All player-ids must be strings"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error with invalid state" do
      payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1"],
        "state" => "invalid-state"
      }

      assert {:error,
              "Invalid or missing state. Must be one of: playing, bench, injured, suspended, available, not_available"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error with missing state" do
      payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1"]
      }

      assert {:error,
              "Invalid or missing state. Must be one of: playing, bench, injured, suspended, available, not_available"} =
               UpdatePlayersStateDefinition.validate(%GameState{}, payload)
    end

    test "returns error when player doesn't exist in team", %{game_state: game_state} do
      payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1", "non-existent-player"],
        "state" => "bench"
      }

      assert {:error, "Players not found in home team: non-existent-player"} =
               UpdatePlayersStateDefinition.validate(game_state, payload)
    end

    test "returns error when multiple players don't exist in team", %{game_state: game_state} do
      payload = %{
        "team-type" => "away",
        "player-ids" => ["player-1", "player-2", "player-3"],
        "state" => "playing"
      }

      assert {:error, "Players not found in away team: player-1, player-2"} =
               UpdatePlayersStateDefinition.validate(game_state, payload)
    end
  end

  describe "create/4" do
    test "returns event with correct structure" do
      payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1", "player-2"],
        "state" => "bench"
      }

      assert %Event{
               key: "update-players-state",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1,
               payload: ^payload
             } = UpdatePlayersStateDefinition.create("some-game-id", 10, 1, payload)
    end
  end

  describe "handle/2" do
    test "updates single player state from playing to bench" do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: "player-1",
              state: :playing,
              stats_values: %{"points" => 10}
            },
            %PlayerState{
              id: "player-2",
              state: :bench,
              stats_values: %{"points" => 5}
            }
          ]
        }
      }

      event_payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1"],
        "state" => "bench"
      }

      event = UpdatePlayersStateDefinition.create(game_state.id, 10, 1, event_payload)
      new_game_state = UpdatePlayersStateDefinition.handle(game_state, event)

      # Find the updated player
      updated_player = Enum.find(new_game_state.home_team.players, &(&1.id == "player-1"))
      unchanged_player = Enum.find(new_game_state.home_team.players, &(&1.id == "player-2"))

      assert updated_player.state == :bench
      assert updated_player.stats_values == %{"points" => 10}
      # unchanged
      assert unchanged_player.state == :bench
      # unchanged
      assert unchanged_player.stats_values == %{"points" => 5}
    end

    test "updates multiple players state from bench to playing" do
      game_state = %GameState{
        away_team: %TeamState{
          players: [
            %PlayerState{
              id: "player-1",
              state: :bench,
              stats_values: %{"rebounds" => 3}
            },
            %PlayerState{
              id: "player-2",
              state: :bench,
              stats_values: %{"assists" => 2}
            },
            %PlayerState{
              id: "player-3",
              state: :available,
              stats_values: %{"fouls" => 1}
            }
          ]
        }
      }

      event_payload = %{
        "team-type" => "away",
        "player-ids" => ["player-1", "player-2"],
        "state" => "playing"
      }

      event = UpdatePlayersStateDefinition.create(game_state.id, 20, 2, event_payload)
      new_game_state = UpdatePlayersStateDefinition.handle(game_state, event)

      # Find all players
      player_1 = Enum.find(new_game_state.away_team.players, &(&1.id == "player-1"))
      player_2 = Enum.find(new_game_state.away_team.players, &(&1.id == "player-2"))
      player_3 = Enum.find(new_game_state.away_team.players, &(&1.id == "player-3"))

      # Check updated players
      assert player_1.state == :playing
      # stats preserved
      assert player_1.stats_values == %{"rebounds" => 3}
      assert player_2.state == :playing
      # stats preserved
      assert player_2.stats_values == %{"assists" => 2}

      # Check unchanged player
      # unchanged
      assert player_3.state == :available
      # unchanged
      assert player_3.stats_values == %{"fouls" => 1}
    end

    test "updates players to injured state" do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: "player-1",
              state: :playing,
              stats_values: %{"minutes" => 15}
            },
            %PlayerState{
              id: "player-2",
              state: :playing,
              stats_values: %{"points" => 8}
            }
          ]
        }
      }

      event_payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1", "player-2"],
        "state" => "injured"
      }

      event = UpdatePlayersStateDefinition.create(game_state.id, 30, 3, event_payload)
      new_game_state = UpdatePlayersStateDefinition.handle(game_state, event)

      # Check both players are now injured
      player_1 = Enum.find(new_game_state.home_team.players, &(&1.id == "player-1"))
      player_2 = Enum.find(new_game_state.home_team.players, &(&1.id == "player-2"))

      assert player_1.state == :injured
      # stats preserved
      assert player_1.stats_values == %{"minutes" => 15}
      assert player_2.state == :injured
      # stats preserved
      assert player_2.stats_values == %{"points" => 8}
    end

    test "updates players to suspended state" do
      game_state = %GameState{
        away_team: %TeamState{
          players: [
            %PlayerState{
              id: "player-1",
              state: :playing,
              stats_values: %{"fouls" => 4}
            }
          ]
        }
      }

      event_payload = %{
        "team-type" => "away",
        "player-ids" => ["player-1"],
        "state" => "suspended"
      }

      event = UpdatePlayersStateDefinition.create(game_state.id, 45, 4, event_payload)
      new_game_state = UpdatePlayersStateDefinition.handle(game_state, event)

      player_1 = Enum.find(new_game_state.away_team.players, &(&1.id == "player-1"))
      assert player_1.state == :suspended
      # stats preserved
      assert player_1.stats_values == %{"fouls" => 4}
    end

    test "updates players to not_available state" do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: "player-1",
              state: :available,
              stats_values: %{"games_played" => 10}
            },
            %PlayerState{
              id: "player-2",
              state: :bench,
              stats_values: %{"minutes" => 25}
            }
          ]
        }
      }

      event_payload = %{
        "team-type" => "home",
        "player-ids" => ["player-1", "player-2"],
        "state" => "not_available"
      }

      event = UpdatePlayersStateDefinition.create(game_state.id, 15, 1, event_payload)
      new_game_state = UpdatePlayersStateDefinition.handle(game_state, event)

      player_1 = Enum.find(new_game_state.home_team.players, &(&1.id == "player-1"))
      player_2 = Enum.find(new_game_state.home_team.players, &(&1.id == "player-2"))

      assert player_1.state == :not_available
      # stats preserved
      assert player_1.stats_values == %{"games_played" => 10}
      assert player_2.state == :not_available
      # stats preserved
      assert player_2.stats_values == %{"minutes" => 25}
    end
  end

  describe "stream_config/0" do
    test "returns default stream config" do
      config = UpdatePlayersStateDefinition.stream_config()
      assert config.streamable == false
    end
  end
end
