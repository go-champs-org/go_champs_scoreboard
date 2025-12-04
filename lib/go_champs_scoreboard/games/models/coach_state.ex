defmodule GoChampsScoreboard.Games.Models.CoachState do
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type state :: :available | :not_available | :disqualified
  @type type :: :head_coach | :assistant_coach

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          type: type(),
          state: state(),
          stats_values: map()
        }
  defstruct [:id, :name, :type, :state, :stats_values]

  @spec new(String.t(), String.t(), type(), state(), map()) :: t()
  def new(
        id,
        name,
        type,
        state \\ :available,
        stats_values \\ Basketball.bootstrap_coach_stats()
      ) do
    %__MODULE__{
      id: id,
      name: name,
      type: type,
      state: state,
      stats_values: stats_values
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.CoachState do
    def decode(
          %{id: id, name: name, type: type, state: state, stats_values: stats_values},
          _options
        ) do
      %GoChampsScoreboard.Games.Models.CoachState{
        state: if(is_nil(state), do: :not_available, else: String.to_atom(state)),
        type: if(is_nil(type), do: :not_available, else: String.to_atom(type)),
        id: id,
        name: name,
        stats_values: stats_values
      }
    end
  end
end
