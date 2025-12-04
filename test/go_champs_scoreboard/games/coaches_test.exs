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

  describe "update_state" do
    test "updates the coach state with new state" do
      coach_state = %{
        id: "coach-123",
        name: "Phil Jackson",
        type: :head_coach,
        state: :active,
        stats_values: %{"fouls" => 2}
      }

      result = Coaches.update_state(coach_state, :disqualified)

      assert result.state == :disqualified
      assert result.id == "coach-123"
      assert result.name == "Phil Jackson"
      assert result.type == :head_coach
      assert result.stats_values == %{"fouls" => 2}
    end

    test "adds state field if it doesn't exist" do
      coach_state = %{
        id: "coach-456",
        name: "Doc Rivers",
        type: :assistant_coach,
        stats_values: %{"fouls_technical" => 1}
      }

      result = Coaches.update_state(coach_state, :disqualified)

      assert result.state == :disqualified
      assert result.id == "coach-456"
      assert result.name == "Doc Rivers"
      assert result.type == :assistant_coach
      assert result.stats_values == %{"fouls_technical" => 1}
    end

    test "can change state from disqualified back to active" do
      coach_state = %{
        id: "coach-789",
        name: "Steve Kerr",
        type: :head_coach,
        state: :disqualified,
        stats_values: %{"fouls" => 3}
      }

      result = Coaches.update_state(coach_state, :active)

      assert result.state == :active
      assert result.id == "coach-789"
      assert result.name == "Steve Kerr"
      assert result.type == :head_coach
      assert result.stats_values == %{"fouls" => 3}
    end
  end
end
