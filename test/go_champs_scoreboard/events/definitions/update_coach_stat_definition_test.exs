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
                 "stat-id" => "fouls_technical"
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
                 "stat-id" => "fouls_technical"
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
              "fouls_technical" => 1,
              "fouls" => 1
            }
          }
        ],
        total_coach_stats: %{
          "fouls_technical" => 1,
          "fouls" => 1
        },
        total_player_stats: %{},
        stats_values: %{
          "points" => 0,
          "fouls" => 1,
          "total_fouls_technical" => 0
        },
        period_stats: %{}
      },
      away_team: %{
        coaches: [
          %{id: "456", stats_values: %{}}
        ],
        total_coach_stats: %{},
        total_player_stats: %{},
        stats_values: %{
          "points" => 0,
          "fouls" => 0,
          "total_fouls_technical" => 0
        },
        period_stats: %{}
      },
      sport_id: "basketball"
    }

    test "increments coach stats for home team" do
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "coach-id" => "123",
        "stat-id" => "fouls_technical"
      }

      event = UpdateCoachStatDefinition.create("some-game-id", 10, 1, payload)

      expected_state = %GameState{
        home_team: %{
          coaches: [
            %{
              id: "123",
              stats_values: %{
                "fouls_technical" => 2,
                "fouls" => 2
              }
            }
          ],
          total_coach_stats: %{
            "fouls_technical" => 2,
            "fouls" => 2
          },
          total_player_stats: %{},
          stats_values: %{
            "points" => 0,
            "fouls" => 2,
            "total_fouls_technical" => 0
          },
          period_stats: %{
            "1" => %{
              "points" => 0,
              "fouls" => 2,
              "total_fouls_technical" => 0
            }
          }
        },
        away_team: %{
          coaches: [
            %{id: "456", stats_values: %{}}
          ],
          total_coach_stats: %{},
          total_player_stats: %{},
          stats_values: %{
            "points" => 0,
            "fouls" => 0,
            "total_fouls_technical" => 0
          },
          period_stats: %{}
        },
        sport_id: "basketball"
      }

      assert UpdateCoachStatDefinition.handle(@initial_state, event) == expected_state
    end
  end
end
