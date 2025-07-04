defmodule GoChampsScoreboard.Events.Definitions.UpdateCoachInTeamDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.UpdateCoachInTeamDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, CoachState}

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               UpdateCoachInTeamDefinition.validate(game_state, %{
                 "team-type" => "home",
                 "coach" => %{
                   "id" => "some-id",
                   "name" => "Pat Riley",
                   "type" => "head_coach"
                 }
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "update-coach-in-team",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdateCoachInTeamDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "coach" => %{
                   "id" => "some-id",
                   "name" => "Pat Riley",
                   "type" => "head_coach"
                 }
               })
    end
  end

  describe "handle/2" do
    test "returns the game state with updated coach" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          coaches: []
        },
        home_team: %TeamState{
          coaches: [%CoachState{id: "some-id", name: "Pat Riley", type: :head_coach}]
        }
      }

      update_coach_in_team_payload = %{
        "team-type" => "home",
        "coach" => %{
          "id" => "some-id",
          "name" => "Doc Rivers",
          "type" => "assistant_coach"
        }
      }

      event =
        UpdateCoachInTeamDefinition.create(game_state.id, 10, 1, update_coach_in_team_payload)

      game = UpdateCoachInTeamDefinition.handle(game_state, event)
      [coach] = game.home_team.coaches

      assert coach.name == "Doc Rivers"
      assert coach.type == :assistant_coach
    end
  end
end
