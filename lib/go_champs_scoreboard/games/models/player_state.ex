defmodule GoChampsScoreboard.Games.Models.PlayerState do
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type state :: :playing | :bench | :injured | :disqualified | :available | :not_available

  @valid_states [:playing, :bench, :injured, :disqualified, :available, :not_available]

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

  @spec valid_states() :: [state()]
  def valid_states, do: @valid_states

  @spec string_to_state(String.t()) :: {:ok, state()} | {:error, String.t()}
  def string_to_state(state_string) when is_binary(state_string) do
    state_atom = String.to_atom(state_string)

    if state_atom in @valid_states do
      {:ok, state_atom}
    else
      {:error, "Invalid state: #{state_string}"}
    end
  end

  @spec valid_state_string?(String.t()) :: boolean()
  def valid_state_string?(state_string) when is_binary(state_string) do
    state_string
    |> String.to_atom()
    |> then(&(&1 in @valid_states))
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
