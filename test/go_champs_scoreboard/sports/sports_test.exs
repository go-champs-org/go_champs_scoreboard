defmodule GoChampsScoreboard.Sports.SportsTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Sports

  describe "find_player_stat_by_type/2" do
    test "delegates to Basketball.Basketball.find_player_stat_by_type for basketball sport" do
      calculated_stats = Sports.find_player_stat_by_type("basketball", [:calculated])
      assert length(calculated_stats) == 10
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)

      manual_stats = Sports.find_player_stat_by_type("basketball", [:manual])
      assert length(manual_stats) > 0
      assert Enum.all?(manual_stats, fn stat -> stat.type == :manual end)

      automatic_stats = Sports.find_player_stat_by_type("basketball", [:automatic])
      assert length(automatic_stats) == 1
      assert Enum.all?(automatic_stats, fn stat -> stat.type == :automatic end)
      assert List.first(automatic_stats).key == "minutes_played"
    end

    test "returns stats matching multiple types for basketball" do
      mixed_stats = Sports.find_player_stat_by_type("basketball", [:calculated, :automatic])
      calculated_count = length(Sports.find_player_stat_by_type("basketball", [:calculated]))
      automatic_count = length(Sports.find_player_stat_by_type("basketball", [:automatic]))

      assert length(mixed_stats) == calculated_count + automatic_count
      assert Enum.all?(mixed_stats, fn stat -> stat.type in [:calculated, :automatic] end)
    end

    test "returns empty list when no stats match the given types" do
      result = Sports.find_player_stat_by_type("basketball", [:non_existent_type])
      assert result == []
    end

    test "returns empty list when given empty types list" do
      result = Sports.find_player_stat_by_type("basketball", [])
      assert result == []
    end
  end

  describe "find_coach_stat/2" do
    test "delegates to Basketball.Basketball.find_coach_stat for basketball sport" do
      technical_foul_stat = Sports.find_coach_stat("basketball", "fouls_technical")
      assert technical_foul_stat.key == "fouls_technical"
      assert technical_foul_stat.type == :manual
      assert technical_foul_stat.operations == [:increment, :decrement]

      disqualifying_foul_stat = Sports.find_coach_stat("basketball", "fouls_disqualifying")
      assert disqualifying_foul_stat.key == "fouls_disqualifying"
      assert disqualifying_foul_stat.type == :manual

      bench_foul_stat = Sports.find_coach_stat("basketball", "fouls_technical_bench")
      assert bench_foul_stat.key == "fouls_technical_bench"
      assert bench_foul_stat.type == :manual

      game_disq_stat = Sports.find_coach_stat("basketball", "fouls_game_disqualifying")
      assert game_disq_stat.key == "fouls_game_disqualifying"
      assert game_disq_stat.type == :manual
    end

    test "returns nil for non-existent coach stat" do
      result = Sports.find_coach_stat("basketball", "non-existing-coach-stat")
      assert result == nil
    end
  end

  describe "find_calculated_coach_stats/1" do
    test "delegates to Basketball.Basketball.find_calculated_coach_stats for basketball sport" do
      calculated_stats = Sports.find_calculated_coach_stats("basketball")

      assert length(calculated_stats) > 0
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)

      calculated_keys = Enum.map(calculated_stats, & &1.key)
      assert "fouls" in calculated_keys
    end
  end

  describe "update_player_state/2" do
    test "delegates to Basketball.Basketball.update_player_state for basketball sport" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "test-player",
        stats_values: %{"fouls" => 3}
      }

      result = Sports.update_player_state("basketball", player)

      # Since the basketball implementation currently returns the player unchanged,
      # we verify the delegation works and returns the same player
      assert result == player
      assert result.id == "test-player"
      assert result.stats_values["fouls"] == 3
    end
  end

  describe "add_game_asset/3" do
    test "adds a new asset to the info state" do
      initial_info_state = %GoChampsScoreboard.Games.Models.InfoState{
        assets: [
          %{type: "logo", url: "http://example.com/logo1.png"},
          %{type: "banner", url: "http://example.com/banner1.png"}
        ]
      }

      updated_info_state =
        Sports.add_game_asset(
          "random_sport",
          initial_info_state,
          "logo",
          "http://example.com/logo2.png"
        )

      assert length(updated_info_state.assets) == 3

      assert Enum.any?(updated_info_state.assets, fn asset ->
               asset.type == "logo" and asset.url == "http://example.com/logo2.png"
             end)
    end
  end
end
