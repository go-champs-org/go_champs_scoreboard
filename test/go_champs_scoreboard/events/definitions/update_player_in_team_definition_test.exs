defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayerInTeamDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerInTeamDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, PlayerState}

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               UpdatePlayerInTeamDefinition.validate(game_state, %{
                 "team-type" => "home",
                 "player" => %{
                   "id" => "some-id",
                   "name" => "Michael Jordan",
                   "number" => 23
                 }
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "update-player-in-team",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdatePlayerInTeamDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "player" => %{
                   "id" => "some-id",
                   "name" => "Michael Jordan",
                   "number" => 23
                 }
               })
    end
  end

  describe "handle/2" do
    test "returns the game state with updated player" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: [%PlayerState{id: "some-id", name: "Kobe Bryant", number: 24}]
        }
      }

      update_player_in_team_payload = %{
        "team-type" => "home",
        "player" => %{
          "id" => "some-id",
          "name" => "Michael Jordan",
          "number" => 23
        }
      }

      event =
        UpdatePlayerInTeamDefinition.create(game_state.id, 10, 1, update_player_in_team_payload)

      game = UpdatePlayerInTeamDefinition.handle(game_state, event)
      [player] = game.home_team.players

      assert player.name == "Michael Jordan"
      assert player.number == 23
    end
  end

  test "returns the game state with updated player when no value is assign to property" do
    game_state = %GameState{
      id: "1",
      away_team: %TeamState{
        players: []
      },
      home_team: %TeamState{
        players: [%PlayerState{id: "some-id", name: "Kobe Bryant", number: 24}]
      }
    }

    update_player_in_team_payload = %{
      "team-type" => "home",
      "player" => %{
        "id" => "some-id",
        "name" => "Kobe Bryant",
        "number" => 24,
        "license_number" => "KB24"
      }
    }

    event =
      UpdatePlayerInTeamDefinition.create(game_state.id, 10, 1, update_player_in_team_payload)

    game = UpdatePlayerInTeamDefinition.handle(game_state, event)
    [player] = game.home_team.players

    assert player.name == "Kobe Bryant"
    assert player.number == 24
    assert player.license_number == "KB24"
  end

  describe "captain handling" do
    test "sets player as captain when is_captain is true" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: [
            %PlayerState{id: "player-1", name: "Player 1", number: 1, is_captain: false},
            %PlayerState{id: "player-2", name: "Player 2", number: 2, is_captain: false}
          ]
        }
      }

      update_player_payload = %{
        "team-type" => "home",
        "player" => %{
          "id" => "player-1",
          "is_captain" => true
        }
      }

      event = UpdatePlayerInTeamDefinition.create(game_state.id, 10, 1, update_player_payload)
      updated_game = UpdatePlayerInTeamDefinition.handle(game_state, event)

      captain_player = Enum.find(updated_game.home_team.players, &(&1.id == "player-1"))
      other_player = Enum.find(updated_game.home_team.players, &(&1.id == "player-2"))

      assert captain_player.is_captain == true
      assert other_player.is_captain == false
    end

    test "removes captain status from previous captain when setting new captain" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: [
            %PlayerState{id: "player-1", name: "Player 1", number: 1, is_captain: true},
            %PlayerState{id: "player-2", name: "Player 2", number: 2, is_captain: false}
          ]
        }
      }

      update_player_payload = %{
        "team-type" => "home",
        "player" => %{
          "id" => "player-2",
          "is_captain" => true
        }
      }

      event = UpdatePlayerInTeamDefinition.create(game_state.id, 10, 1, update_player_payload)
      updated_game = UpdatePlayerInTeamDefinition.handle(game_state, event)

      old_captain = Enum.find(updated_game.home_team.players, &(&1.id == "player-1"))
      new_captain = Enum.find(updated_game.home_team.players, &(&1.id == "player-2"))

      assert old_captain.is_captain == false
      assert new_captain.is_captain == true
    end

    test "removes captain status when is_captain is false" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: [
            %PlayerState{id: "player-1", name: "Player 1", number: 1, is_captain: true}
          ]
        }
      }

      update_player_payload = %{
        "team-type" => "home",
        "player" => %{
          "id" => "player-1",
          "is_captain" => false
        }
      }

      event = UpdatePlayerInTeamDefinition.create(game_state.id, 10, 1, update_player_payload)
      updated_game = UpdatePlayerInTeamDefinition.handle(game_state, event)

      player = Enum.find(updated_game.home_team.players, &(&1.id == "player-1"))
      assert player.is_captain == false
    end

    test "does not affect captain status when is_captain is not provided" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: [
            %PlayerState{id: "player-1", name: "Player 1", number: 1, is_captain: true}
          ]
        }
      }

      update_player_payload = %{
        "team-type" => "home",
        "player" => %{
          "id" => "player-1",
          "name" => "Updated Player 1"
        }
      }

      event = UpdatePlayerInTeamDefinition.create(game_state.id, 10, 1, update_player_payload)
      updated_game = UpdatePlayerInTeamDefinition.handle(game_state, event)

      player = Enum.find(updated_game.home_team.players, &(&1.id == "player-1"))
      assert player.is_captain == true
      assert player.name == "Updated Player 1"
    end
  end
end
