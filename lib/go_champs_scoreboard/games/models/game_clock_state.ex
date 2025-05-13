defmodule GoChampsScoreboard.Games.Models.GameClockState do
  @derive [Poison.Encoder]
  @type state :: :not_started | :running | :paused | :stopped

  @type t :: %__MODULE__{
          initial_period_time: integer,
          initial_extra_period_time: integer,
          time: integer,
          period: integer,
          state: state
        }

  defstruct [:initial_period_time, :initial_extra_period_time, :time, :period, :state]

  @spec new(integer(), integer(), integer(), String.t()) :: t()
  def new(
        initial_period_time \\ 0,
        initial_extra_period_time \\ 0,
        time \\ 0,
        period \\ 1,
        state \\ :not_started
      ) do
    %__MODULE__{
      initial_period_time: initial_period_time,
      initial_extra_period_time: initial_extra_period_time,
      time: time,
      period: period,
      state: state
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.GameClockState do
    def decode(
          %{
            initial_period_time: initial_period_time,
            initial_extra_period_time: initial_extra_period_time,
            time: time,
            period: period,
            state: state
          },
          _options
        ) do
      %GoChampsScoreboard.Games.Models.GameClockState{
        initial_period_time: initial_period_time,
        initial_extra_period_time: initial_extra_period_time,
        time: time,
        period: period,
        state: String.to_atom(state)
      }
    end
  end
end
