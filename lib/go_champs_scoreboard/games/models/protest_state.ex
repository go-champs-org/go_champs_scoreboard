defmodule GoChampsScoreboard.Games.Models.ProtestState do
  @type state :: :no_protest | :protest_filed

  @type t :: %__MODULE__{
          team_id: String.t(),
          player_id: String.t(),
          state: state()
        }
  defstruct [:team_id, :player_id, :state]

  @spec new(String.t(), String.t(), state()) :: t()
  def new(team_id, player_id, state \\ :no_protest) do
    %__MODULE__{
      team_id: team_id,
      player_id: player_id,
      state: state
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.ProtestState do
    def decode(
          %{
            team_id: team_id,
            player_id: player_id,
            state: state
          },
          _options
        ) do
      %GoChampsScoreboard.Games.Models.ProtestState{
        team_id: team_id,
        player_id: player_id,
        state: if(is_nil(state), do: :no_protest, else: String.to_atom(state))
      }
    end
  end
end
