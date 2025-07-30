defmodule GoChampsScoreboard.Sports.SportsTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Sports

  describe "find_player_stat_by_type/2" do
    test "delegates to Basketball.Basketball.find_player_stat_by_type for basketball sport" do
      # Test with calculated stats
      calculated_stats = Sports.find_player_stat_by_type("basketball", [:calculated])
      assert length(calculated_stats) == 9
      assert Enum.all?(calculated_stats, fn stat -> stat.type == :calculated end)

      # Test with manual stats
      manual_stats = Sports.find_player_stat_by_type("basketball", [:manual])
      assert length(manual_stats) > 0
      assert Enum.all?(manual_stats, fn stat -> stat.type == :manual end)

      # Test with automatic stats
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
end
