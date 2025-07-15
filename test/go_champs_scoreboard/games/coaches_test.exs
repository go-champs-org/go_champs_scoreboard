defmodule GoChampsScoreboard.Games.CoachesTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Coaches
  alias GoChampsScoreboard.Statistics.Models.Stat

  describe "bootstrap" do
    test "returns a new coach state with new random id, given name and number" do
      coach_state = Coaches.bootstrap("Phil Jackson", :head_coach)

      assert is_bitstring(coach_state.id)
      assert "Phil Jackson" == coach_state.name
      assert :head_coach == coach_state.type
    end
  end

  describe "update_manual_stats_values" do
    test "updates the coach state with the new value" do
      coach_state = %{
        stats_values: %{
          "one-points-made" => 1
        }
      }

      coach_stat = Stat.new("one-points-made", :manual, [:increment])

      assert %{
               stats_values: %{
                 "one-points-made" => 2
               }
             } == Coaches.update_manual_stats_values(coach_state, coach_stat, "increment")
    end

    test "does not update the coach state if new value is negative" do
      coach_state = %{
        stats_values: %{
          "one-points-made" => 0
        }
      }

      coach_stat = Stat.new("one-points-made", :manual, [:decrement])

      assert %{
               stats_values: %{
                 "one-points-made" => 0
               }
             } == Coaches.update_manual_stats_values(coach_state, coach_stat, "decrement")
    end
  end

  describe "update_calculated_stats_values" do
    test "updates the coach state with the new value" do
      coach_state = %{
        stats_values: %{
          "two-points-made" => 5,
          "def-rebounds" => 2,
          "points" => 0,
          "rebounds" => 0
        }
      }

      coach_stats = [
        Stat.new(
          "points",
          :calculated,
          [],
          fn coach_state -> coach_state.stats_values["two-points-made"] * 2 end
        ),
        Stat.new(
          "rebounds",
          :calculated,
          [],
          fn coach_state -> coach_state.stats_values["def-rebounds"] + 1 end
        )
      ]

      assert %{
               stats_values: %{
                 "two-points-made" => 5,
                 "def-rebounds" => 2,
                 "points" => 10,
                 "rebounds" => 3
               }
             } == Coaches.update_calculated_stats_values(coach_state, coach_stats)
    end
  end
end
