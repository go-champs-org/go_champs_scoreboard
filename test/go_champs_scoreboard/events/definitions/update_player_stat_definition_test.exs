defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               UpdatePlayerStatDefinition.validate(game_state, %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "player-id" => "123",
                 "stat-id" => "field_goals_made"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "update-player-stat",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdatePlayerStatDefinition.create("some-game-id", 10, 1, %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "player-id" => "123",
                 "stat-id" => "field_goals_made"
               })
    end
  end

  describe "handle/2" do
    @initial_state %GameState{
      home_team: %{
        players: [
          %{
            id: "123",
            stats_values: %{
              "field_goals_made" => 1,
              "points" => 2,
              "rebounds" => 0
            }
          }
        ],
        total_player_stats: %{
          "field_goals_made" => 1,
          "points" => 2,
          "rebounds" => 0
        },
        total_coach_stats: %{},
        stats_values: %{
          "points" => 2,
          "fouls" => 0,
          "total_fouls_technical" => 0
        },
        period_stats: %{}
      },
      away_team: %{
        players: [
          %{id: "456", stats_values: %{}}
        ],
        total_player_stats: %{},
        total_coach_stats: %{},
        stats_values: %{
          "points" => 0,
          "fouls" => 0,
          "total_fouls_technical" => 0
        },
        period_stats: %{}
      },
      sport_id: "basketball"
    }

    test "increments player stats for home team" do
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event = UpdatePlayerStatDefinition.create("some-game-id", 10, 1, payload)

      expected_state = %GameState{
        home_team: %{
          players: [
            %{
              id: "123",
              stats_values: %{
                "field_goals_made" => 2,
                "points" => 4,
                "rebounds" => 0
              }
            }
          ],
          total_player_stats: %{
            "field_goals_made" => 2,
            "points" => 4,
            "rebounds" => 0
          },
          total_coach_stats: %{},
          stats_values: %{
            "points" => 4,
            "fouls" => 0,
            "total_fouls_technical" => 0
          },
          period_stats: %{
            "1" => %{
              "points" => 4,
              "fouls" => 0,
              "total_fouls_technical" => 0
            }
          }
        },
        away_team: %{
          players: [
            %{id: "456", stats_values: %{}}
          ],
          total_player_stats: %{},
          total_coach_stats: %{},
          stats_values: %{
            "points" => 0,
            "fouls" => 0,
            "total_fouls_technical" => 0
          },
          period_stats: %{}
        },
        sport_id: "basketball"
      }

      assert UpdatePlayerStatDefinition.handle(@initial_state, event) == expected_state
    end

    test "handles player state update integration" do
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event = UpdatePlayerStatDefinition.create("some-game-id", 10, 1, payload)

      # Test that the function completes successfully with player state update
      result = UpdatePlayerStatDefinition.handle(@initial_state, event)

      # Verify the player was updated and the state update didn't cause issues
      home_player = List.first(result.home_team.players)
      assert home_player.id == "123"
      assert home_player.stats_values["field_goals_made"] == 2
      assert home_player.stats_values["points"] == 4

      # Verify team totals were calculated correctly
      assert result.home_team.total_player_stats["field_goals_made"] == 2
      assert result.home_team.stats_values["points"] == 4
    end

    test "disqualifies player when fouls reach 5" do
      initial_state = %GameState{
        home_team: %{
          players: [
            %{
              id: "player-123",
              state: :playing,
              stats_values: %{
                "fouls_personal" => 4,
                "fouls" => 4
              }
            }
          ],
          total_player_stats: %{
            "fouls_personal" => 4,
            "fouls" => 4
          },
          total_coach_stats: %{},
          stats_values: %{
            "points" => 0,
            "fouls" => 4,
            "total_fouls_technical" => 0
          },
          period_stats: %{}
        },
        away_team: %{
          players: [],
          total_player_stats: %{},
          total_coach_stats: %{},
          stats_values: %{
            "points" => 0,
            "fouls" => 0,
            "total_fouls_technical" => 0
          },
          period_stats: %{}
        },
        sport_id: "basketball"
      }

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "player-123",
        "stat-id" => "fouls_personal"
      }

      event = UpdatePlayerStatDefinition.create("some-game-id", 10, 1, payload)
      result = UpdatePlayerStatDefinition.handle(initial_state, event)

      # Verify the player was updated and disqualified
      home_player = List.first(result.home_team.players)
      assert home_player.id == "player-123"
      assert home_player.stats_values["fouls_personal"] == 5
      assert home_player.stats_values["fouls"] == 5
      assert home_player.state == :disqualified

      # Verify team totals were calculated correctly
      assert result.home_team.total_player_stats["fouls_personal"] == 5
      assert result.home_team.stats_values["fouls"] == 5
    end
  end
end
