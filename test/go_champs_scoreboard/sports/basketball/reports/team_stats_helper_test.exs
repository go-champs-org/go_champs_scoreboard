defmodule GoChampsScoreboard.Sports.Basketball.Reports.TeamStatsHelperTest do
  use ExUnit.Case, async: true

  alias GoChampsScoreboard.Sports.Basketball.Reports.TeamStatsHelper
  alias GoChampsScoreboard.Games.Models.TeamState

  describe "map_points_by_period/1" do
    test "maps period stats to points by period correctly" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"points" => 25},
          2 => %{"points" => 18},
          3 => %{"points" => 22},
          4 => %{"points" => 20}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{1 => 25, 2 => 18, 3 => 22, 4 => 20}
    end

    test "handles empty period_stats map" do
      team_state = %TeamState{
        period_stats: %{}
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{}
    end

    test "defaults to 0 when points key is missing" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"rebounds" => 10},
          2 => %{"assists" => 5}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{1 => 0, 2 => 0}
    end

    test "defaults to 0 when points value is nil" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"points" => nil},
          2 => %{"points" => 15}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{1 => 0, 2 => 15}
    end

    test "handles mixed scenarios with some periods having points and others not" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"points" => 12},
          2 => %{"rebounds" => 8},
          3 => %{"points" => nil},
          4 => %{"points" => 20},
          5 => %{"assists" => 3}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{1 => 12, 2 => 0, 3 => 0, 4 => 20, 5 => 0}
    end

    test "preserves period numbers as integer keys" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"points" => 10},
          3 => %{"points" => 15},
          5 => %{"points" => 8}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert Map.keys(result) |> Enum.all?(&is_integer/1)
      assert result == %{1 => 10, 3 => 15, 5 => 8}
    end

    test "handles overtime periods" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"points" => 25},
          2 => %{"points" => 20},
          3 => %{"points" => 22},
          4 => %{"points" => 23},
          # First overtime
          5 => %{"points" => 8},
          # Second overtime
          6 => %{"points" => 6}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{1 => 25, 2 => 20, 3 => 22, 4 => 23, 5 => 8, 6 => 6}
    end

    test "handles missing period_stats field gracefully" do
      team_state = %TeamState{
        name: "Test Team"
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert result == %{}
    end

    test "ensures all values are integers" do
      team_state = %TeamState{
        period_stats: %{
          1 => %{"points" => 15},
          2 => %{"points" => 0},
          3 => %{"points" => 25}
        }
      }

      result = TeamStatsHelper.map_points_by_period(team_state)

      assert Map.values(result) |> Enum.all?(&is_integer/1)
    end
  end
end
