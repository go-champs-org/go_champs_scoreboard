defmodule GoChampsScoreboard.Games.Models.GameClockState do
  @derive [Poison.Encoder]
  @type state :: :not_started | :running | :paused | :stopped | :finished

  @type t :: %__MODULE__{
          initial_period_time: integer,
          initial_extra_period_time: integer,
          time: integer,
          period: integer,
          state: state,
          started_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil
        }

  defstruct [
    :initial_period_time,
    :initial_extra_period_time,
    :time,
    :period,
    :state,
    :started_at,
    :finished_at
  ]

  @spec new(
          integer(),
          integer(),
          integer(),
          integer(),
          atom(),
          DateTime.t() | nil,
          DateTime.t() | nil
        ) :: t()
  def new(
        initial_period_time \\ 0,
        initial_extra_period_time \\ 0,
        time \\ 0,
        period \\ 1,
        state \\ :not_started,
        started_at \\ nil,
        finished_at \\ nil
      ) do
    %__MODULE__{
      initial_period_time: initial_period_time,
      initial_extra_period_time: initial_extra_period_time,
      time: time,
      period: period,
      state: state,
      started_at: started_at,
      finished_at: finished_at
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.GameClockState do
    def decode(
          %{
            initial_period_time: initial_period_time,
            initial_extra_period_time: initial_extra_period_time,
            time: time,
            period: period,
            state: state,
            started_at: started_at,
            finished_at: finished_at
          },
          _options
        ) do
      %GoChampsScoreboard.Games.Models.GameClockState{
        initial_period_time: initial_period_time,
        initial_extra_period_time: initial_extra_period_time,
        time: time,
        period: period,
        state: String.to_atom(state),
        started_at: parse_datetime(started_at),
        finished_at: parse_datetime(finished_at)
      }
    end

    defp parse_datetime(nil), do: nil

    defp parse_datetime(datetime_string) when is_binary(datetime_string) do
      case DateTime.from_iso8601(datetime_string) do
        {:ok, datetime, _} -> datetime
        {:error, _} -> nil
      end
    end

    defp parse_datetime(datetime), do: datetime
  end
end
