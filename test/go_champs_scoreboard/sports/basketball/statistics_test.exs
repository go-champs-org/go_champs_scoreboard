defmodule GoChampsScoreboard.Sports.Basketball.StatisticsTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Sports.Basketball.Statistics

  describe "calc_player_efficiency" do
    test "returns the sum of points (1pt for FTM, 2pt for FGM, 3pt for 3PM), RO, RD, ASS, STL, BLK, and subtracts FTMM, FGMM, 3PMM and TO" do
      # Player with 20 points, 10 rebounds, 5 assists, 3 steals, 2 blocks,
      # 4 missed free throws, 6 missed field goals, 2 missed three point field goals, and 3 turnovers
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "free_throws_made" => 4,
          "field_goals_made" => 5,
          "three_point_field_goals_made" => 2,
          "rebounds_offensive" => 3,
          "rebounds_defensive" => 7,
          "assists" => 5,
          "steals" => 2,
          "blocks" => 3,
          "free_throws_missed" => 4,
          "field_goals_missed" => 6,
          "three_point_field_goals_missed" => 2,
          "turnovers" => 3
        }
      }

      # Efficiency = (20 + 10 + 5 + 3 + 2) - (4 + 6 + 2 + 3) = 40 - 15 = 25
      assert Statistics.calc_player_efficiency(player_state) == 25
    end
  end

  describe "calc_player_field_goal_percentage" do
    test "returns the percentage of field goals made" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "field_goals_made" => 2,
          "field_goals_missed" => 1
        }
      }

      assert Statistics.calc_player_field_goal_percentage(player_state) == 66.667
    end

    test "returns 0 when no field goals have been made" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "field_goals_made" => 0,
          "field_goals_missed" => 0
        }
      }

      assert Statistics.calc_player_field_goal_percentage(player_state) == 0
    end
  end

  describe "calc_player_field_goals_attempted" do
    test "returns the sum of field_goals_made and field_goals_missed" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "field_goals_made" => 2,
          "field_goals_missed" => 1
        }
      }

      assert Statistics.calc_player_field_goals_attempted(player_state) == 3
    end
  end

  describe "calc_player_fouls" do
    test "returns the sum of personal fouls and technical fouls" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "fouls_personal" => 3,
          "fouls_technical" => 1
        }
      }

      assert Statistics.calc_player_fouls(player_state) == 4
    end

    test "returns 0 when no fouls are recorded" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{}
      }

      assert Statistics.calc_player_fouls(player_state) == 0
    end

    test "handles missing foul fields gracefully" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "fouls_personal" => 2,
          # technical fouls missing
          "other_stat" => 5
        }
      }

      assert Statistics.calc_player_fouls(player_state) == 2
    end

    test "calc_player_fouls includes all foul types when present" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "fouls_personal" => 1,
          "fouls_technical" => 2,
          "fouls_flagrant" => 1,
          "fouls_disqualifying" => 1,
          "fouls_disqualifying_fighting" => 1,
          "fouls_unsportsmanlike" => 1,
          # Other unrelated stats
          "points" => 15,
          "rebounds_total" => 8
        }
      }

      # Should sum ALL foul types
      assert Statistics.calc_player_fouls(player_state) == 7
    end

    test "calc_player_fouls with typical game scenario" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "fouls_personal" => 3,
          "fouls_technical" => 1,
          # No other fouls
          "points" => 20,
          "rebounds_total" => 5
        }
      }

      # Typical scenario: personal fouls + technical foul
      assert Statistics.calc_player_fouls(player_state) == 4
    end
  end

  describe "calc_player_free_throw_percentage" do
    test "returns the percentage of free throws made" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "free_throws_made" => 2,
          "free_throws_missed" => 1
        }
      }

      assert Statistics.calc_player_free_throw_percentage(player_state) == 66.667
    end

    test "returns 0 when no free throws have been made" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "free_throws_made" => 0,
          "free_throws_missed" => 0
        }
      }

      assert Statistics.calc_player_free_throw_percentage(player_state) == 0
    end
  end

  describe "calc_player_free_throws_attempted" do
    test "returns the sum of free_throws_made and free_throws_missed" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "free_throws_made" => 2,
          "free_throws_missed" => 1
        }
      }

      assert Statistics.calc_player_free_throws_attempted(player_state) == 3
    end
  end

  describe "calc_player_points" do
    test "returns the sum of (1 * one-points-made), (2 * field_goals_made), and (3 * three-points-made)" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "free_throws_made" => 1,
          "field_goals_made" => 2,
          "three_point_field_goals_made" => 3
        }
      }

      assert Statistics.calc_player_points(player_state) == 14
    end
  end

  describe "calc_player_rebounds" do
    test "returns them sum of off-rebounds and def-rebounds" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "rebounds_defensive" => 2,
          "rebounds_offensive" => 1
        }
      }

      assert Statistics.calc_player_rebounds(player_state) == 3
    end
  end

  describe "calc_player_three_point_field_goal_percentage" do
    test "returns the percentage of three-point field goals made" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "three_point_field_goals_made" => 2,
          "three_point_field_goals_missed" => 1
        }
      }

      assert Statistics.calc_player_three_point_field_goal_percentage(player_state) == 66.667
    end

    test "returns 0 when no three-point field goals have been made" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "three_point_field_goals_made" => 0,
          "three_point_field_goals_missed" => 0
        }
      }

      assert Statistics.calc_player_three_point_field_goal_percentage(player_state) == 0
    end
  end

  describe "calc_player_three_point_field_goals_attempted" do
    test "returns the sum of three_point_field_goals_made and three_point_field_goals_missed" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "three_point_field_goals_made" => 2,
          "three_point_field_goals_missed" => 1
        }
      }

      assert Statistics.calc_player_three_point_field_goals_attempted(player_state) == 3
    end
  end

  describe "calc_team_technical_fouls" do
    test "returns them sum of personal-fouls and technical-fouls" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{
          "fouls_technical" => 1
        },
        stats_values: %{
          "fouls_technical" => 1
        }
      }

      assert Statistics.calc_team_technical_fouls(team_state) == 2
    end
  end

  describe "calc_team_points" do
    test "returns the total player stats points" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{
          "points" => 85
        },
        stats_values: %{}
      }

      assert Statistics.calc_team_points(team_state) == 85
    end

    test "returns 20 when team has a walkover against" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        stats_values: %{
          "game_walkover_against" => 1
        },
        total_player_stats: %{}
      }

      assert Statistics.calc_team_points(team_state) == 20
    end

    test "returns 0 when no points in total_player_stats" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{},
        stats_values: %{}
      }

      assert Statistics.calc_team_points(team_state) == 0
    end
  end

  describe "calc_team_fouls" do
    test "returns the sum of specific player foul types" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{
          "fouls_disqualifying" => 1,
          "fouls_flagrant" => 2,
          "fouls_personal" => 8,
          "fouls_technical" => 3,
          "fouls_unsportsmanlike" => 1
        },
        total_coach_stats: %{
          "fouls" => 5
        }
      }

      # Should only count specific player fouls, not coach fouls
      assert Statistics.calc_team_fouls(team_state) == 15
    end

    test "returns only specific player fouls when they exist" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{
          "fouls_personal" => 6,
          "fouls_technical" => 2
        },
        total_coach_stats: %{
          "fouls" => 3
        }
      }

      # Should only count the specific player fouls, not coach fouls
      assert Statistics.calc_team_fouls(team_state) == 8
    end

    test "returns 0 when no specific player foul types are present" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{
          # Has other stats but not the specific fouls we count
          "points" => 85,
          "rebounds" => 45
        },
        total_coach_stats: %{
          "fouls" => 2
        }
      }

      assert Statistics.calc_team_fouls(team_state) == 0
    end

    test "does not count fouls_disqualifying_fighting and fouls_game_disqualifying" do
      team_state = %GoChampsScoreboard.Games.Models.TeamState{
        total_player_stats: %{
          "fouls_personal" => 5,
          "fouls_technical" => 2,
          # These should NOT be counted
          "fouls_disqualifying_fighting" => 3,
          "fouls_game_disqualifying" => 2
        },
        total_coach_stats: %{
          "fouls" => 1
        }
      }

      # Should only count fouls_personal (5) + fouls_technical (2) = 7
      # Should NOT count fouls_disqualifying_fighting or fouls_game_disqualifying
      assert Statistics.calc_team_fouls(team_state) == 7
    end
  end

  describe "calc_coach_fouls" do
    test "returns the number of technical fouls for the coach" do
      coach_state = %GoChampsScoreboard.Games.Models.CoachState{
        stats_values: %{
          "fouls_technical" => 2,
          "fouls_disqualifying" => 1,
          "fouls_technical_bench" => 1,
          "fouls_technical_bench_disqualifying" => 1,
          "fouls_game_disqualifying" => 2
        }
      }

      assert Statistics.calc_coach_fouls(coach_state) == 6
    end
  end

  describe "calc_player_plus_minus" do
    setup do
      game_state = %GoChampsScoreboard.Games.Models.GameState{}
      %{game_state: game_state}
    end

    test "returns current plus_minus when player is not playing", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :bench,
        stats_values: %{
          "plus_minus" => 5
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "home"
        )

      assert result == 5
    end

    test "adds 2 points when player is playing and own team scores field goal", %{
      game_state: game_state
    } do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => 0
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "home"
        )

      assert result == 2
    end

    test "subtracts 2 points when player is playing and opponent scores field goal", %{
      game_state: game_state
    } do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => 0
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "away"
        )

      assert result == -2
    end

    test "adds 1 point for free throw made", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => 5
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "away",
          "free_throws_made",
          "increment",
          "away"
        )

      assert result == 6
    end

    test "adds 3 points for three-pointer made", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => -2
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "three_point_field_goals_made",
          "increment",
          "home"
        )

      assert result == 1
    end

    test "handles decrement operation (undo scoring)", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => 10
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "decrement",
          "home"
        )

      assert result == 8
    end

    test "handles decrement of opponent score", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => -5
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "three_point_field_goals_made",
          "decrement",
          "away"
        )

      # Decrementing opponent's 3-pointer: -5 - (-3) = -2
      assert result == -2
    end

    test "returns current value for non-scoring stats", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => 7
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "rebounds_defensive",
          "increment",
          "home"
        )

      assert result == 7
    end

    test "accumulates over multiple scoring events", %{game_state: game_state} do
      # Start with 0
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{
          "plus_minus" => 0
        }
      }

      # Event 1: Team scores field goal (+2)
      result1 =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "home"
        )

      assert result1 == 2

      # Event 2: Opponent scores three-pointer (-3)
      player_state2 = %{player_state | stats_values: %{"plus_minus" => result1}}

      result2 =
        Statistics.calc_player_plus_minus(
          player_state2,
          game_state,
          "home",
          "three_point_field_goals_made",
          "increment",
          "away"
        )

      assert result2 == -1

      # Event 3: Team scores free throw (+1)
      player_state3 = %{player_state | stats_values: %{"plus_minus" => result2}}

      result3 =
        Statistics.calc_player_plus_minus(
          player_state3,
          game_state,
          "home",
          "free_throws_made",
          "increment",
          "home"
        )

      assert result3 == 0
    end

    test "handles injured player state (not playing)", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :injured,
        stats_values: %{
          "plus_minus" => 3
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "home"
        )

      assert result == 3
    end

    test "handles missing plus_minus stat (defaults to 0)", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        state: :playing,
        stats_values: %{}
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "home"
        )

      assert result == 2
    end

    test "handles missing state field (defaults to bench)", %{game_state: game_state} do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "plus_minus" => 4
        }
      }

      result =
        Statistics.calc_player_plus_minus(
          player_state,
          game_state,
          "home",
          "field_goals_made",
          "increment",
          "home"
        )

      # Should return unchanged since state defaults to :bench
      assert result == 4
    end
  end
end
