defmodule GoChampsScoreboard.Games.Models.PlayerState do
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type state :: :playing | :bench | :injured | :suspended | :available | :not_available

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          number: String.t(),
          license_number: String.t() | nil,
          state: state(),
          stats_values: map(),
          is_captain: boolean()
        }
  defstruct [:id, :name, :number, :license_number, :state, :stats_values, :is_captain]

  @spec new(String.t(), String.t(), String.t(), String.t(), state(), map(), boolean()) :: t()
  def new(
        id,
        name,
        number \\ "0",
        license_number \\ "",
        state \\ :available,
        stats_values \\ Basketball.bootstrap_player_stats(),
        is_captain \\ false
      ) do
    %__MODULE__{
      id: id,
      name: name,
      number: number,
      license_number: license_number,
      state: state,
      stats_values: stats_values,
      is_captain: is_captain
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.PlayerState do
    def decode(
          %{
            id: id,
            name: name,
            number: number,
            license_number: license_number,
            state: state,
            stats_values: stats_values,
            is_captain: is_captain
          },
          _options
        ) do
      %GoChampsScoreboard.Games.Models.PlayerState{
        state: if(is_nil(state), do: :not_available, else: String.to_atom(state)),
        id: id,
        name: name,
        number: number,
        license_number: license_number,
        stats_values: stats_values,
        is_captain: if(is_nil(is_captain), do: false, else: is_captain)
      }
    end
  end
end
