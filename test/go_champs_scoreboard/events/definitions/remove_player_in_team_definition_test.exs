defmodule GoChampsScoreboard.Events.Definitions.RemovePlayerInTeamDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, PlayerState}
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.RemovePlayerInTeamDefinition

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               RemovePlayerInTeamDefinition.validate(game_state, %{
                 "team-type" => "home",
                 "player-id" => "some-id"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "remove-player-in-team",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               RemovePlayerInTeamDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "player-id" => "some-id"
               })
    end
  end

  describe "handle/2" do
    test "returns game state with player removed" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: "some-id",
              name: "Kobe Bryant",
              number: 24
            }
          ]
        }
      }

      remove_player_in_team_payload = %{
        "team-type" => "home",
        "player-id" => "some-id"
      }

      event =
        RemovePlayerInTeamDefinition.create(game_state.id, 10, 1, remove_player_in_team_payload)

      game = RemovePlayerInTeamDefinition.handle(game_state, event)
      players = game.home_team.players

      assert Enum.empty?(players)
    end
  end
end
