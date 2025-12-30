defmodule GoChampsScoreboard.Sports.Basketball.GameClock do
  alias GoChampsScoreboard.Games.Models.GameClockState

  # Five minutes in seconds
  @initial_extra_period_time 300

  @spec advance_to(GameClockState.t(), GameClockState.state()) :: GameClockState.t()
  def advance_to(clock_state, state) do
    case {clock_state.state, state} do
      {:not_started, new_state} ->
        %GameClockState{clock_state | state: new_state, started_at: DateTime.utc_now()}

      {:finished, _} ->
        clock_state

      {_, :finished} ->
        %GameClockState{clock_state | state: :finished, finished_at: DateTime.utc_now()}

      {_, new_state} ->
        %GameClockState{clock_state | state: new_state}
    end
  end

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

  @spec start_game(GameClockState.t()) :: GameClockState.t()
  def start_game(clock_state) do
    advance_to(clock_state, :running)
  end

  @spec end_game(GameClockState.t()) :: GameClockState.t()
  def end_game(clock_state) do
    advance_to(clock_state, :finished)
  end

  @spec set_clock_for_wo(GameClockState.t()) :: GameClockState.t()
  def set_clock_for_wo(clock_state) do
    %GameClockState{clock_state | time: 0, period: 4, state: :paused}
  end
end
