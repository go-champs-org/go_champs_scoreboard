defmodule GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{
        home_team: %{
          players: [
            %{
              id: "123",
              stats_values: %{}
            }
          ]
        },
        away_team: %{
          players: [
            %{id: "456", stats_values: %{}}
          ]
        }
      }

      assert {:ok} =
               UpdateTeamStatDefinition.validate(game_state, %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "stat-id" => "fouls_technical"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "update-team-stat",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdateTeamStatDefinition.create("some-game-id", 10, 1, %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "stat-id" => "fouls_technical"
               })
    end
  end

  describe "handle/2" do
    @initial_state %GameState{
      home_team: %{
        players: [
          %{
            id: "123",
            stats_values: %{}
          }
        ],
        total_player_stats: %{},
        stats_values: %{
          "fouls_technical" => 0,
          "total_fouls_technical" => 0
        },
        period_stats: %{}
      },
      away_team: %{
        players: [
          %{id: "456", stats_values: %{}}
        ],
        total_player_stats: %{},
        stats_values: %{},
        period_stats: %{}
      },
      sport_id: "basketball"
    }

    test "increments team stats for home team" do
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "stat-id" => "fouls_technical"
      }

      event = UpdateTeamStatDefinition.create("game-id", 10, 1, payload)

      expected_state = %GameState{
        home_team: %{
          players: [
            %{
              id: "123",
              stats_values: %{}
            }
          ],
          total_player_stats: %{},
          stats_values: %{
            "fouls_technical" => 1,
            "total_fouls_technical" => 1
          },
          period_stats: %{
            "1" => %{"fouls_technical" => 1, "total_fouls_technical" => 1}
          }
        },
        away_team: %{
          players: [
            %{id: "456", stats_values: %{}}
          ],
          total_player_stats: %{},
          stats_values: %{},
          period_stats: %{}
        },
        sport_id: "basketball"
      }

      assert UpdateTeamStatDefinition.handle(@initial_state, event) == expected_state
    end
  end
end
