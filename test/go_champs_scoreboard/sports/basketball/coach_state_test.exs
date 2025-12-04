defmodule GoChampsScoreboard.Sports.Basketball.CoachStateTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Basketball.CoachState

  describe "update_coach_state/1" do
    test "returns the same coach when called with low fouls" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "test-coach-1",
        stats_values: %{
          "fouls" => 1,
          "fouls_technical" => 1
        }
      }

      result = CoachState.update_coach_state(coach)

      assert result == coach
      assert result.id == "test-coach-1"
      assert result.stats_values["fouls"] == 1
      assert result.stats_values["fouls_technical"] == 1
    end

    test "handles coach with empty stats" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "empty-stats-coach",
        stats_values: %{}
      }

      result = CoachState.update_coach_state(coach)

      assert result == coach
      assert result.id == "empty-stats-coach"
      assert result.stats_values == %{}
    end

    test "disqualifies coach with 3 fouls" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "three-fouls-coach",
        state: :active,
        stats_values: %{"fouls" => 3}
      }

      result = CoachState.update_coach_state(coach)

      # Coach should be disqualified when fouls >= 3
      assert result.stats_values["fouls"] == 3
      assert result.state == :disqualified
    end

    test "disqualifies coach with more than 3 fouls" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "high-fouls-coach",
        state: :active,
        stats_values: %{"fouls" => 5}
      }

      result = CoachState.update_coach_state(coach)

      # Coach should be disqualified when fouls >= 3
      assert result.stats_values["fouls"] == 5
      assert result.state == :disqualified
    end

    test "does not change state when coach has less than 3 fouls" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "low-fouls-coach",
        state: :active,
        stats_values: %{"fouls" => 2}
      }

      result = CoachState.update_coach_state(coach)

      # Coach should remain in current state when fouls < 3
      assert result.stats_values["fouls"] == 2
      assert result.state == :active
    end

    test "does not change state when coach is already disqualified" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "already-disqualified-coach",
        state: :disqualified,
        stats_values: %{"fouls" => 4}
      }

      result = CoachState.update_coach_state(coach)

      # Coach should remain disqualified (no state change)
      assert result.stats_values["fouls"] == 4
      assert result.state == :disqualified
    end

    test "disqualifies coach with 1 game disqualifying foul" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "game-disqualifying-coach",
        state: :active,
        stats_values: %{
          "fouls" => 1,
          "fouls_game_disqualifying" => 1
        }
      }

      result = CoachState.update_coach_state(coach)

      # Coach should be disqualified with 1 game disqualifying foul
      assert result.stats_values["fouls"] == 1
      assert result.stats_values["fouls_game_disqualifying"] == 1
      assert result.state == :disqualified
    end

    test "does not disqualify coach with 0 game disqualifying fouls and less than 3 regular fouls" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "safe-coach",
        state: :active,
        stats_values: %{
          "fouls" => 2,
          "fouls_game_disqualifying" => 0
        }
      }

      result = CoachState.update_coach_state(coach)

      # Coach should remain in current state
      assert result.stats_values["fouls"] == 2
      assert result.stats_values["fouls_game_disqualifying"] == 0
      assert result.state == :active
    end

    test "disqualifies coach with game disqualifying foul even if already disqualified" do
      coach = %GoChampsScoreboard.Games.Models.CoachState{
        id: "already-disqualified-with-game-foul",
        state: :disqualified,
        stats_values: %{
          "fouls" => 4,
          "fouls_game_disqualifying" => 1
        }
      }

      result = CoachState.update_coach_state(coach)

      # Coach should remain disqualified (no state change)
      assert result.stats_values["fouls"] == 4
      assert result.stats_values["fouls_game_disqualifying"] == 1
      assert result.state == :disqualified
    end
  end
end
