defmodule GoChampsScoreboard.Sports.Basketball.GameClock do
  alias GoChampsScoreboard.Games.Models.GameClockState

  # Five minutes in seconds
  @initial_extra_period_time 300

  @spec tick(GameClockState.t()) :: GameClockState.t()
  def tick(clock_state) do
    case clock_state.state do
      :running when clock_state.time > 0 ->
        %GameClockState{clock_state | time: clock_state.time - 1}

      :running when clock_state.time == 0 ->
        %GameClockState{clock_state | state: :paused}

      _ ->
        clock_state
    end
  end

  @spec end_period(GameClockState.t()) :: GameClockState.t()
  def end_period(clock_state) do
    case {clock_state.time, clock_state.period, clock_state.state} do
      {0, period, :paused} when period >= 1 and period <= 3 ->
        %GameClockState{
          clock_state
          | period: clock_state.period + 1,
            time: clock_state.initial_period_time
        }

      {0, period, :paused} when period >= 4 ->
        %GameClockState{
          clock_state
          | period: clock_state.period + 1,
            time: @initial_extra_period_time
        }

      {_, _, _} ->
        clock_state
    end
  end
end
