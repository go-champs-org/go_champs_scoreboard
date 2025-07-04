defmodule GoChampsScoreboard.Events.Definitions.RemoveCoachInTeamDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, CoachState}
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.RemoveCoachInTeamDefinition

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               RemoveCoachInTeamDefinition.validate(game_state, %{
                 "team-type" => "home",
                 "coach-id" => "some-id"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "remove-coach-in-team",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               RemoveCoachInTeamDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "coach-id" => "some-id"
               })
    end
  end

  describe "handle/2" do
    test "returns game state with coach removed" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          coaches: []
        },
        home_team: %TeamState{
          coaches: [
            %CoachState{
              id: "some-id",
              name: "Gregg Popovich",
              type: :head_coach
            }
          ]
        }
      }

      remove_coach_in_team_payload = %{
        "team-type" => "home",
        "coach-id" => "some-id"
      }

      event =
        RemoveCoachInTeamDefinition.create(game_state.id, 10, 1, remove_coach_in_team_payload)

      game = RemoveCoachInTeamDefinition.handle(game_state, event)
      coaches = game.home_team.coaches

      assert Enum.empty?(coaches)
    end
  end
end
