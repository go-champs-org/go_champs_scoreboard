defmodule GoChampsScoreboard.Games.Models.LiveState do
  @derive [Poison.Encoder]
  @type state :: :not_started | :in_progress | :ended

  @type t :: %__MODULE__{
          state: state,
          started_at: DateTime.t() | nil,
          ended_at: DateTime.t() | nil
        }

  defstruct [:state, :started_at, :ended_at]

  @spec new() :: t()
  @spec new(state()) :: t()
  def new(state \\ :not_started) do
    %__MODULE__{
      state: state,
      started_at: nil,
      ended_at: nil
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.LiveState do
    def decode(
          %{state: state, started_at: started_at, ended_at: ended_at} = _values,
          _options
        ) do
      DateTime.from_iso8601(state)

      started_at =
        if started_at do
          DateTime.from_iso8601(started_at)
          |> elem(1)
        else
          nil
        end

      ended_at =
        if ended_at do
          DateTime.from_iso8601(ended_at)
          |> elem(1)
        else
          nil
        end

      %GoChampsScoreboard.Games.Models.LiveState{
        state: String.to_atom(state),
        started_at: started_at,
        ended_at: ended_at
      }
    end
  end
end
