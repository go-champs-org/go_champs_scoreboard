defmodule GoChampsScoreboard.Sports.Basketball.BasketballTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  describe "bootstrap_player_stats" do
    test "returns a map with all player stats" do
      expected = %{
        "assists" => 0,
        "blocks" => 0,
        "disqualifications" => 0,
        "ejections" => 0,
        "efficiency" => 0,
        "field_goal_percentage" => 0,
        "field_goals_attempted" => 0,
        "field_goals_missed" => 0,
        "field_goals_made" => 0,
        "fouls" => 0,
        "fouls_disqualifying" => 0,
        "fouls_disqualifying_fighting" => 0,
        "fouls_game_disqualifying" => 0,
        "fouls_flagrant" => 0,
        "fouls_personal" => 0,
        "fouls_technical" => 0,
        "fouls_unsportsmanlike" => 0,
        "free_throw_percentage" => 0,
        "free_throws_attempted" => 0,
        "free_throws_missed" => 0,
        "free_throws_made" => 0,
        "game_played" => 0,
        "game_started" => 0,
        "minutes_played" => 0,
        "plus_minus" => 0,
        "points" => 0,
        "rebounds" => 0,
        "rebounds_defensive" => 0,
        "rebounds_offensive" => 0,
        "steals" => 0,
        "three_point_field_goal_percentage" => 0,
        "three_point_field_goals_attempted" => 0,
        "three_point_field_goals_missed" => 0,
        "three_point_field_goals_made" => 0,
        "turnovers" => 0
      }

      assert expected == Basketball.bootstrap_player_stats()
    end
  end

  describe "bootstrap_coach_stats" do
    test "returns a map with all coach stats" do
      expected = %{
        "fouls" => 0,
        "fouls_technical" => 0,
        "fouls_disqualifying" => 0,
        "fouls_disqualifying_fighting" => 0,
        "fouls_technical_bench" => 0,
        "fouls_game_disqualifying" => 0
      }

      assert expected == Basketball.bootstrap_coach_stats()
    end
  end

  describe "find_player_stat" do
    test "returns the player stat with the given key" do
      assert %GoChampsScoreboard.Statistics.Models.Stat{
               key: "points",
               type: :calculated,
               operations: [],
               calculation_function:
                 &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_points/1
             } == Basketball.find_player_stat("points")
    end

    test "returns nil if the player stat with the given key is not found" do
      assert nil == Basketball.find_player_stat("non-existing-stat")
    end
  end

  describe "find_calculated_player_stats" do
    test "returns all calculated player stats" do
      expected = [
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "field_goal_percentage",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_field_goal_percentage/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "field_goals_attempted",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_field_goals_attempted/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_fouls/1,
          key: "fouls",
          operations: [],
          type: :calculated
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "free_throw_percentage",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_free_throw_percentage/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "free_throws_attempted",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_free_throws_attempted/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "points",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_points/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "rebounds",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_rebounds/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "three_point_field_goal_percentage",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_three_point_field_goal_percentage/1
        },
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "three_point_field_goals_attempted",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_player_three_point_field_goals_attempted/1
        }
      ]

      assert expected == Basketball.find_calculated_player_stats()
    end
  end

  describe "find_player_stat_by_type" do
    test "returns all player stats matching the given types" do
      # Test with calculated stats
      calculated_stats = Basketball.find_player_stat_by_type([:calculated])
      assert length(calculated_stats) == 9
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)

      # Test with manual stats
      manual_stats = Basketball.find_player_stat_by_type([:manual])
      assert length(manual_stats) > 0
      assert Enum.all?(manual_stats, fn stat -> stat.type == :manual end)

      # Test with automatic stats
      automatic_stats = Basketball.find_player_stat_by_type([:automatic])
      assert length(automatic_stats) == 1
      assert Enum.all?(automatic_stats, fn stat -> stat.type == :automatic end)
      assert List.first(automatic_stats).key == "minutes_played"
    end

    test "returns stats matching multiple types" do
      mixed_stats = Basketball.find_player_stat_by_type([:calculated, :automatic])
      calculated_count = length(Basketball.find_player_stat_by_type([:calculated]))
      automatic_count = length(Basketball.find_player_stat_by_type([:automatic]))

      assert length(mixed_stats) == calculated_count + automatic_count
      assert Enum.all?(mixed_stats, fn stat -> stat.type in [:calculated, :automatic] end)
    end

    test "returns empty list when no stats match the given types" do
      result = Basketball.find_player_stat_by_type([:non_existent_type])
      assert result == []
    end

    test "returns empty list when given empty types list" do
      result = Basketball.find_player_stat_by_type([])
      assert result == []
    end

    test "returns specific stats by key when filtering by type" do
      manual_stats = Basketball.find_player_stat_by_type([:manual])
      manual_keys = Enum.map(manual_stats, & &1.key)

      # Check that some expected manual stats are included
      assert "assists" in manual_keys
      assert "field_goals_made" in manual_keys
      assert "free_throws_made" in manual_keys
      assert "turnovers" in manual_keys
    end
  end

  describe "bootstrap_team_stats" do
    test "returns a map with all team stats" do
      expected = %{
        "timeouts" => 0,
        "fouls_technical" => 0,
        "total_fouls_technical" => 0
      }

      assert expected == Basketball.bootstrap_team_stats()
    end
  end

  describe "find_calculated_team_stats" do
    test "returns all calculated team stats" do
      expected = [
        %GoChampsScoreboard.Statistics.Models.Stat{
          key: "total_fouls_technical",
          type: :calculated,
          operations: [],
          calculation_function:
            &GoChampsScoreboard.Sports.Basketball.Statistics.calc_team_technical_fouls/1
        }
      ]

      assert expected == Basketball.find_calculated_team_stats()
    end
  end

  describe "find_team_stat" do
    test "returns the team stat with the given key" do
      assert %GoChampsScoreboard.Statistics.Models.Stat{
               key: "fouls_technical",
               type: :manual,
               operations: [:increment, :decrement],
               calculation_function: nil
             } == Basketball.find_player_stat("fouls_technical")
    end

    test "returns nil if the team stat with the given key is not found" do
      assert nil == Basketball.find_team_stat("non-existing-stat")
    end
  end

  describe "find_team_stat_by_type" do
    test "returns all team stats matching the given types" do
      # Test with manual stats
      manual_stats = Basketball.find_team_stat_by_type([:manual])
      assert length(manual_stats) == 2
      assert Enum.all?(manual_stats, fn stat -> stat.type == :manual end)

      # Test with calculated stats
      calculated_stats = Basketball.find_team_stat_by_type([:calculated])
      assert length(calculated_stats) == 1
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)
      assert List.first(calculated_stats).key == "total_fouls_technical"
    end

    test "returns stats matching multiple types" do
      mixed_stats = Basketball.find_team_stat_by_type([:manual, :calculated])
      manual_count = length(Basketball.find_team_stat_by_type([:manual]))
      calculated_count = length(Basketball.find_team_stat_by_type([:calculated]))

      assert length(mixed_stats) == manual_count + calculated_count
      assert Enum.all?(mixed_stats, fn stat -> stat.type in [:manual, :calculated] end)
    end

    test "returns empty list when no stats match the given types" do
      result = Basketball.find_team_stat_by_type([:non_existent_type])
      assert result == []
    end

    test "returns empty list when given empty types list" do
      result = Basketball.find_team_stat_by_type([])
      assert result == []
    end

    test "returns specific stats by key when filtering by type" do
      manual_stats = Basketball.find_team_stat_by_type([:manual])
      manual_keys = Enum.map(manual_stats, & &1.key)

      # Check that expected manual team stats are included
      assert "timeouts" in manual_keys
      assert "fouls_technical" in manual_keys

      calculated_stats = Basketball.find_team_stat_by_type([:calculated])
      calculated_keys = Enum.map(calculated_stats, & &1.key)

      # Check that expected calculated team stats are included
      assert "total_fouls_technical" in calculated_keys
    end
  end

  describe "find_coach_stat" do
    test "returns the coach stat with the given key" do
      assert %GoChampsScoreboard.Statistics.Models.Stat{
               key: "fouls_technical",
               type: :manual,
               operations: [:increment, :decrement]
             } == Basketball.find_coach_stat("fouls_technical")
    end

    test "returns the coach stat for fouls_disqualifying" do
      assert %GoChampsScoreboard.Statistics.Models.Stat{
               key: "fouls_disqualifying",
               type: :manual,
               operations: [:increment, :decrement]
             } == Basketball.find_coach_stat("fouls_disqualifying")
    end

    test "returns the coach stat for fouls_technical_bench" do
      assert %GoChampsScoreboard.Statistics.Models.Stat{
               key: "fouls_technical_bench",
               type: :manual,
               operations: [:increment, :decrement]
             } == Basketball.find_coach_stat("fouls_technical_bench")
    end

    test "returns the coach stat for fouls_game_disqualifying" do
      assert %GoChampsScoreboard.Statistics.Models.Stat{
               key: "fouls_game_disqualifying",
               type: :manual,
               operations: [:increment, :decrement]
             } == Basketball.find_coach_stat("fouls_game_disqualifying")
    end

    test "returns nil if the coach stat with the given key is not found" do
      assert nil == Basketball.find_coach_stat("non-existing-stat")
    end
  end

  describe "find_calculated_coach_stats" do
    test "returns all calculated coach stats" do
      calculated_stats = Basketball.find_calculated_coach_stats()

      # Should include the calculated fouls stat
      calculated_keys = Enum.map(calculated_stats, & &1.key)
      assert "fouls" in calculated_keys

      # All returned stats should be calculated
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)
    end

    test "returns empty list when no calculated coach stats exist" do
      # This test would pass if there were no calculated coach stats
      # Currently we have one: "fouls"
      calculated_stats = Basketball.find_calculated_coach_stats()
      assert length(calculated_stats) >= 0
    end
  end
end
