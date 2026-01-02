defmodule GoChampsScoreboard.Games.Models.CoachState do
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type state :: :available | :not_available | :disqualified
  @type type :: :head_coach | :assistant_coach

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          type: type(),
          state: state(),
          stats_values: map(),
          signature: String.t() | nil
        }
  defstruct [:id, :name, :type, :state, :stats_values, :signature]

  @spec new(String.t(), String.t(), type(), state(), map(), String.t() | nil) :: t()
  def new(
        id,
        name,
        type,
        state \\ :available,
        stats_values \\ Basketball.bootstrap_coach_stats(),
        signature \\ nil
      ) do
    %__MODULE__{
      id: id,
      name: name,
      type: type,
      state: state,
      stats_values: stats_values,
      signature: signature
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.CoachState do
    def decode(
          %{
            id: id,
            name: name,
            type: type,
            state: state,
            stats_values: stats_values,
            signature: signature
          } = _value,
          _options
        ) do
      %GoChampsScoreboard.Games.Models.CoachState{
        state: if(is_nil(state), do: :not_available, else: String.to_atom(state)),
        type: if(is_nil(type), do: :not_available, else: String.to_atom(type)),
        id: id,
        name: name,
        stats_values: stats_values,
        signature: signature
      }
    end
  end
end
