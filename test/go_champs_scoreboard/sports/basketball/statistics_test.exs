defmodule GoChampsScoreboard.Sports.Basketball.StatisticsTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Sports.Basketball.Statistics

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
    test "returns them sum of personal-fouls and technical-fouls" do
      player_state = %GoChampsScoreboard.Games.Models.PlayerState{
        stats_values: %{
          "fouls_personal" => 3,
          "fouls_technical" => 1
        }
      }

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
end
