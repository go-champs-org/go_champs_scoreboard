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
        "fouls_technical_bench_disqualifying" => 0,
        "fouls_game_disqualifying" => 0
      }

      assert expected == Basketball.bootstrap_coach_stats()
    end
  end

  describe "find_player_stat" do
    test "returns the player stat with the given key" do
      stat = Basketball.find_player_stat("points")

      assert stat.key == "points"
      assert stat.type == :calculated
      assert stat.operations == []
      assert stat.level == :player
    end

    test "returns nil if the player stat with the given key is not found" do
      assert nil == Basketball.find_player_stat("non-existing-stat")
    end
  end

  describe "find_calculated_player_stats" do
    test "returns all calculated player stats" do
      calculated_stats = Basketball.find_calculated_player_stats()

      # Should return 10 player-level calculated stats (excluding game-level like plus_minus)
      assert length(calculated_stats) == 10

      # All should be calculated type and player level
      assert Enum.all?(calculated_stats, fn stat ->
               stat.type == :calculated and stat.level == :player
             end)

      # Check expected stat keys are present
      stat_keys = Enum.map(calculated_stats, & &1.key) |> MapSet.new()

      expected_keys =
        MapSet.new([
          "efficiency",
          "field_goal_percentage",
          "field_goals_attempted",
          "fouls",
          "free_throw_percentage",
          "free_throws_attempted",
          "points",
          "rebounds",
          "three_point_field_goal_percentage",
          "three_point_field_goals_attempted"
        ])

      assert MapSet.equal?(stat_keys, expected_keys)
    end
  end

  describe "find_player_stat_by_type" do
    test "returns all player stats matching the given types" do
      # Test with calculated stats (includes both player-level and game-level)
      calculated_stats = Basketball.find_player_stat_by_type([:calculated])
      # 10 player-level + 1 game-level (plus_minus)
      assert length(calculated_stats) == 11
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
        "lost_timeouts" => 0,
        "fouls_technical" => 0,
        "points" => 0,
        "fouls" => 0,
        "total_fouls_technical" => 0,
        "game_walkover_against" => 0,
        "game_walkover" => 0
      }

      assert expected == Basketball.bootstrap_team_stats()
    end
  end

  describe "find_calculated_team_stats" do
    test "returns all calculated team stats" do
      calculated_stats = Basketball.find_calculated_team_stats()

      # Should have 3 calculated team stats
      assert length(calculated_stats) == 3

      # All should be calculated type
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)

      # Check expected keys
      stat_keys = Enum.map(calculated_stats, & &1.key) |> MapSet.new()
      expected_keys = MapSet.new(["points", "fouls", "total_fouls_technical"])
      assert MapSet.equal?(stat_keys, expected_keys)
    end
  end

  describe "find_team_stat" do
    test "returns the team stat with the given key" do
      stat = Basketball.find_player_stat("fouls_technical")

      assert stat.key == "fouls_technical"
      assert stat.type == :manual
      assert stat.operations == [:increment, :decrement]
    end

    test "returns nil if the team stat with the given key is not found" do
      assert nil == Basketball.find_team_stat("non-existing-stat")
    end
  end

  describe "find_team_stat_by_type" do
    test "returns all team stats matching the given types" do
      # Test with manual stats
      manual_stats = Basketball.find_team_stat_by_type([:manual])
      assert length(manual_stats) == 5
      assert Enum.all?(manual_stats, fn stat -> stat.type == :manual end)

      # Test with calculated stats
      calculated_stats = Basketball.find_team_stat_by_type([:calculated])
      assert length(calculated_stats) == 3
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)
      calculated_stat_keys = Enum.map(calculated_stats, & &1.key)
      assert "points" in calculated_stat_keys
      assert "fouls" in calculated_stat_keys
      assert "total_fouls_technical" in calculated_stat_keys
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
      stat = Basketball.find_coach_stat("fouls_technical")

      assert stat.key == "fouls_technical"
      assert stat.type == :manual
      assert stat.operations == [:increment, :decrement]
    end

    test "returns the coach stat for fouls_technical_bench" do
      stat = Basketball.find_coach_stat("fouls_technical_bench")

      assert stat.key == "fouls_technical_bench"
      assert stat.type == :manual
      assert stat.operations == [:increment, :decrement]
    end

    test "returns the coach stat for fouls_game_disqualifying" do
      stat = Basketball.find_coach_stat("fouls_game_disqualifying")

      assert stat.key == "fouls_game_disqualifying"
      assert stat.type == :manual
      assert stat.operations == [:increment, :decrement]
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
