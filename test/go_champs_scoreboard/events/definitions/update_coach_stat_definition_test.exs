defmodule GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               UpdateCoachStatDefinition.validate(game_state, %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "coach-id" => "123",
                 "stat-id" => "field_goals_made"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "update-coach-stat",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdateCoachStatDefinition.create("some-game-id", 10, 1, %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "coach-id" => "123",
                 "stat-id" => "field_goals_made"
               })
    end
  end

  describe "handle/2" do
    @initial_state %GameState{
      home_team: %{
        coaches: [
          %{
            id: "123",
            stats_values: %{
              "field_goals_made" => 1,
              "points" => 2,
              "rebounds" => 0
            }
          }
        ]
      },
      away_team: %{
        coaches: [
          %{id: "456", stats_values: %{}}
        ]
      },
      sport_id: "basketball"
    }

    test "increments coach stats for home team" do
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "coach-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event = UpdateCoachStatDefinition.create("some-game-id", 10, 1, payload)

      expected_state = %GameState{
        home_team: %{
          coaches: [
            %{
              id: "123",
              stats_values: %{
                "field_goals_made" => 2,
                "points" => 4,
                "rebounds" => 0
              }
            }
          ]
        },
        away_team: %{
          coaches: [
            %{id: "456", stats_values: %{}}
          ]
        },
        sport_id: "basketball"
      }

      assert UpdateCoachStatDefinition.handle(@initial_state, event) == expected_state
    end
  end
end
