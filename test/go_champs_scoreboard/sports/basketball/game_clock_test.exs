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

  describe "end_period" do
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

      assert expected == GameClock.end_period(game_clock_state)
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

      assert expected == GameClock.end_period(game_clock_state)
    end
  end

  describe "advance_to" do
    test "when clock_state is :not_started, it moves to the next state and updates started_at time" do
      game_clock_state = %GameClockState{
        time: 600,
        period: 1,
        state: :not_started,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: nil,
        finished_at: nil
      }

      result = GameClock.advance_to(game_clock_state, :running)

      assert result.state == :running
      assert result.time == 600
      assert result.period == 1
      assert result.initial_period_time == 600
      assert result.initial_extra_period_time == 300
      assert result.finished_at == nil
      assert result.started_at != nil
      assert DateTime.diff(DateTime.utc_now(), result.started_at, :second) < 1
    end

    test "when clock_state is :not_started, it can advance to :paused and updates started_at time" do
      game_clock_state = %GameClockState{
        time: 600,
        period: 1,
        state: :not_started,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: nil,
        finished_at: nil
      }

      result = GameClock.advance_to(game_clock_state, :paused)

      assert result.state == :paused
      assert result.started_at != nil
      assert DateTime.diff(DateTime.utc_now(), result.started_at, :second) < 1
    end

    test "when clock_state is :running, it only updates the state property" do
      started_time = DateTime.utc_now()

      game_clock_state = %GameClockState{
        time: 500,
        period: 2,
        state: :running,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: nil
      }

      result = GameClock.advance_to(game_clock_state, :paused)

      expected = %GameClockState{
        time: 500,
        period: 2,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: nil
      }

      assert result == expected
    end

    test "when clock_state is :paused, it only updates the state property" do
      started_time = DateTime.utc_now()

      game_clock_state = %GameClockState{
        time: 400,
        period: 3,
        state: :paused,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: nil
      }

      result = GameClock.advance_to(game_clock_state, :running)

      expected = %GameClockState{
        time: 400,
        period: 3,
        state: :running,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: nil
      }

      assert result == expected
    end

    test "when clock_state is :stopped, it only updates the state property" do
      started_time = DateTime.utc_now()

      game_clock_state = %GameClockState{
        time: 0,
        period: 4,
        state: :stopped,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: nil
      }

      result = GameClock.advance_to(game_clock_state, :finished)

      expected = %GameClockState{
        time: 0,
        period: 4,
        state: :finished,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: nil
      }

      assert result == expected
    end

    test "when clock_state is :finished, it doesn't change anything" do
      started_time = DateTime.utc_now()
      finished_time = DateTime.utc_now()

      game_clock_state = %GameClockState{
        time: 0,
        period: 4,
        state: :finished,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: finished_time
      }

      result = GameClock.advance_to(game_clock_state, :running)

      assert result == game_clock_state
    end

    test "when clock_state is :finished, it doesn't change regardless of target state" do
      started_time = DateTime.utc_now()
      finished_time = DateTime.utc_now()

      game_clock_state = %GameClockState{
        time: 100,
        period: 3,
        state: :finished,
        initial_period_time: 600,
        initial_extra_period_time: 300,
        started_at: started_time,
        finished_at: finished_time
      }

      assert GameClock.advance_to(game_clock_state, :running) == game_clock_state
      assert GameClock.advance_to(game_clock_state, :paused) == game_clock_state
      assert GameClock.advance_to(game_clock_state, :stopped) == game_clock_state
      assert GameClock.advance_to(game_clock_state, :not_started) == game_clock_state
    end

    test "preserves all other properties when advancing from any state" do
      started_time = DateTime.utc_now()

      game_clock_state = %GameClockState{
        time: 123,
        period: 7,
        state: :running,
        initial_period_time: 800,
        initial_extra_period_time: 400,
        started_at: started_time,
        finished_at: nil
      }

      result = GameClock.advance_to(game_clock_state, :stopped)

      assert result.time == 123
      assert result.period == 7
      assert result.initial_period_time == 800
      assert result.initial_extra_period_time == 400
      assert result.started_at == started_time
      assert result.finished_at == nil
      assert result.state == :stopped
    end
  end
end
