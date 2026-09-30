defmodule GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState

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
            "fouls" => 0,
            "total_fouls_technical" => 0
          },
          period_stats: %{
            "1" => %{
              "points" => 0,
              "fouls" => 0,
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

    test "disqualifies coach when fouls reach 3" do
      initial_state = %GameState{
        home_team: %{
          coaches: [
            %{
              id: "coach-123",
              state: :active,
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
          period_stats: %{}
        },
        away_team: %{
          coaches: [],
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

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "coach-id" => "coach-123",
        "stat-id" => "fouls_technical"
      }

      event = UpdateCoachStatDefinition.create("some-game-id", 10, 1, payload)
      result = UpdateCoachStatDefinition.handle(initial_state, event)

      # Verify the coach was updated and disqualified
      home_coach = List.first(result.home_team.coaches)
      assert home_coach.id == "coach-123"
      assert home_coach.stats_values["fouls_technical"] == 3
      assert home_coach.stats_values["fouls"] == 3
      assert home_coach.state == :disqualified

      # Verify team totals were calculated correctly
      assert result.home_team.total_coach_stats["fouls_technical"] == 3
      assert result.home_team.stats_values["fouls"] == 0
    end

    test "stamps last_action_time and last_action_period on clock_state" do
      initial_state = %{
        @initial_state
        | clock_state: %GameClockState{
            time: 240,
            period: 3,
            last_action_time: nil,
            last_action_period: nil
          }
      }

      event =
        UpdateCoachStatDefinition.create("some-game-id", 240, 3, %{
          "operation" => "increment",
          "team-type" => "home",
          "coach-id" => "123",
          "stat-id" => "fouls_technical"
        })

      result = UpdateCoachStatDefinition.handle(initial_state, event)

      assert result.clock_state.last_action_time == 240
      assert result.clock_state.last_action_period == 3
    end

    test "handles non-existent coach gracefully" do
      initial_state = %GameState{
        home_team: %{
          coaches: [
            %{
              id: "coach-123",
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
          coaches: [],
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

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "coach-id" => "non-existent-coach",
        "stat-id" => "fouls_technical"
      }

      event = UpdateCoachStatDefinition.create("some-game-id", 10, 1, payload)
      result = UpdateCoachStatDefinition.handle(initial_state, event)

      # Game state should remain unchanged
      assert result == initial_state
    end
  end

  describe "handle/2 with FIBA 2026 bench fouls" do
    import GoChampsScoreboard.GameStateFixtures

    alias GoChampsScoreboard.Games.Models.ViewSettingsState
    alias GoChampsScoreboard.Sports.Basketball.Basketball

    defp game_state_with_coach(stats_values) do
      game_state_with_players_fixture(
        home_coaches: [
          %{
            id: "coach-id",
            stats_values: Map.merge(Basketball.bootstrap_coach_stats(), stats_values)
          }
        ],
        view_settings_state: ViewSettingsState.new("basketball-medium-stats", [], "fiba-2026")
      )
    end

    defp increment_home_coach_stat(game_state, stat_id, metadata \\ nil) do
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "coach-id" => "coach-id",
        "stat-id" => stat_id
      }

      payload = if metadata, do: Map.put(payload, "metadata", metadata), else: payload
      event = UpdateCoachStatDefinition.create(game_state.id, 10, 1, payload)

      game_state
      |> UpdateCoachStatDefinition.handle(event)
      |> Map.get(:home_team)
      |> Map.get(:coaches)
      |> Enum.find(&(&1.id == "coach-id"))
    end

    test "disqualifies the coach on 2 technical bench fouls and 1 circled BD" do
      coach =
        %{"fouls_technical_bench" => 2}
        |> game_state_with_coach()
        |> increment_home_coach_stat("fouls_technical_bench_disqualifying_circled")

      assert coach.stats_values["fouls_game_disqualifying"] == 1
      assert coach.state == :disqualified
    end

    test "does not disqualify the coach on 2 technical bench fouls and 1 BD without circle" do
      coach =
        %{"fouls_technical_bench" => 2}
        |> game_state_with_coach()
        |> increment_home_coach_stat("fouls_technical_bench_disqualifying")

      assert coach.stats_values["fouls_game_disqualifying"] == 0
      assert coach.stats_values["fouls"] == 2
      refute Map.get(coach, :state) == :disqualified
    end

    test "counts a BD for two bench members as a single incident" do
      coach =
        %{}
        |> game_state_with_coach()
        |> increment_home_coach_stat("fouls_technical_bench_disqualifying", %{
          "free-throws-awarded" => "2",
          "disqualified-members" => 2
        })

      assert coach.stats_values["fouls_technical_bench_disqualifying"] == 1
    end

    test "records the circled BD for coaches bootstrapped before the stat existed" do
      game_state =
        game_state_with_players_fixture(
          home_coaches: [%{id: "coach-id", stats_values: %{"fouls_technical" => 0}}],
          view_settings_state: ViewSettingsState.new("basketball-medium-stats", [], "fiba-2026")
        )

      coach =
        increment_home_coach_stat(game_state, "fouls_technical_bench_disqualifying_circled")

      assert coach.stats_values["fouls_technical_bench_disqualifying_circled"] == 1
    end
  end
end
