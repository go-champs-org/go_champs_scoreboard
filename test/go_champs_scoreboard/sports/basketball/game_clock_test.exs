defmodule GoChampsScoreboard.Sports.Basketball.GameClockTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Sports.Basketball.GameClock
  alias GoChampsScoreboard.Games.Models.GameClockState

  describe "tick" do
    test "decreases the time by 1 when the game clock is running" do
      game_clock_state = %GameClockState{
        time: 10,
        period: 1,
        state: :running,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      expected = %GameClockState{
        time: 9,
        period: 1,
        state: :running,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      assert expected == GameClock.tick(game_clock_state)
    end

    test "does not change the time when the game clock is not running" do
      game_clock_state = %GameClockState{
        time: 10,
        period: 1,
        state: :stopped,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      expected = %GameClockState{
        time: 10,
        period: 1,
        state: :stopped,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      assert expected == GameClock.tick(game_clock_state)
    end

    test "pauses the clock when is running and time is 0" do
      game_clock_state = %GameClockState{
        time: 0,
        period: 1,
        state: :running,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      expected = %GameClockState{
        time: 0,
        period: 1,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      assert expected == GameClock.tick(game_clock_state)
    end
  end

  describe "next_period" do
    test "increments the period by 1 and time to initial_period_time when time is 0 and state is :paused" do
      game_clock_state = %GameClockState{
        time: 0,
        period: 1,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      expected = %GameClockState{
        time: 600,
        period: 2,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      assert expected == GameClock.next_period(game_clock_state)
    end

    test "increments the period by 1 and resets time to 300 when time is 0 and state is :paused and period is >= 4" do
      game_clock_state = %GameClockState{
        time: 0,
        period: 4,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      expected = %GameClockState{
        time: 300,
        period: 5,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300
      }

      assert expected == GameClock.next_period(game_clock_state)
    end
  end
end
