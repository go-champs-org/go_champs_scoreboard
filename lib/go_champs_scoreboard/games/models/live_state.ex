defmodule GoChampsScoreboard.Games.Models.LiveState do
  @derive [Poison.Encoder]
  @type state :: :not_started | :running | :ended

  @type t :: %__MODULE__{
          state: state
        }

  defstruct [:state]

  @spec new() :: t()
  def new() do
    %__MODULE__{
      state: :not_started
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.LiveState do
    def decode(
          %{state: state},
          _options
        ) do
      %GoChampsScoreboard.Games.Models.LiveState{
        state: String.to_atom(state)
      }
    end
  end
end
