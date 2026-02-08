defmodule GoChampsScoreboard.Events.Definitions.AddPlayerToTeamDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.AddPlayerToTeamDefinition
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.TeamState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               AddPlayerToTeamDefinition.validate(game_state, %{
                 "team-type" => "home",
                 "name" => "Michael Jordan",
                 "number" => 23
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "add-player-to-team",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               AddPlayerToTeamDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "name" => "Michael Jordan",
                 "number" => 23
               })
    end
  end

  describe "handle/2" do
    test "returns the game state with new player" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        }
      }

      add_player_to_team_payload = %{
        "team-type" => "home",
        "name" => "Michael Jordan",
        "number" => 23
      }

      event = AddPlayerToTeamDefinition.create(game_state.id, 10, 1, add_player_to_team_payload)

      game = AddPlayerToTeamDefinition.handle(game_state, event)
      [player] = game.home_team.players

      assert player.name == "Michael Jordan"
      assert player.number == 23
    end

    test "returns the game state with new player using provided id" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        }
      }

      player_id = "existing-player-id-123"

      add_player_to_team_payload = %{
        "team-type" => "home",
        "name" => "Michael Jordan",
        "number" => 23,
        "id" => player_id
      }

      event = AddPlayerToTeamDefinition.create(game_state.id, 10, 1, add_player_to_team_payload)

      game = AddPlayerToTeamDefinition.handle(game_state, event)
      [player] = game.home_team.players

      assert player.id == player_id
      assert player.name == "Michael Jordan"
      assert player.number == 23
    end

    test "generates new id when provided id is invalid" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        }
      }

      add_player_to_team_payload = %{
        "team-type" => "home",
        "name" => "Michael Jordan",
        "number" => 23,
        "id" => 12345
      }

      event = AddPlayerToTeamDefinition.create(game_state.id, 10, 1, add_player_to_team_payload)

      game = AddPlayerToTeamDefinition.handle(game_state, event)
      [player] = game.home_team.players

      # Should generate a new UUID since the provided id is not a string
      assert is_binary(player.id)
      assert player.id != 12345
      assert player.name == "Michael Jordan"
      assert player.number == 23
    end
  end
end
