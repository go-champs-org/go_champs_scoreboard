defmodule GoChampsScoreboard.Events.Definitions.AddCoachToTeamDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.AddCoachToTeamDefinition
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.TeamState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               AddCoachToTeamDefinition.validate(game_state, %{
                 "team-type" => "home",
                 "name" => "Phil Jackson",
                 "type" => "head_coach"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "add-coach-to-team",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               AddCoachToTeamDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "name" => "Phil Jackson",
                 "type" => "head_coach"
               })
    end
  end

  describe "handle/2" do
    test "returns the game state with new coach" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          coaches: []
        },
        home_team: %TeamState{
          coaches: []
        }
      }

      add_coach_to_team_payload = %{
        "team-type" => "home",
        "name" => "Phil Jackson",
        "type" => "head_coach"
      }

      event = AddCoachToTeamDefinition.create(game_state.id, 10, 1, add_coach_to_team_payload)

      game = AddCoachToTeamDefinition.handle(game_state, event)
      [coach] = game.home_team.coaches

      assert coach.name == "Phil Jackson"
      assert coach.type == "head_coach"
    end
  end
end
