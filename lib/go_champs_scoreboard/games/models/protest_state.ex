defmodule GoChampsScoreboard.Games.Models.ProtestState do
  @type state :: :no_protest | :protest_filed
  @type team_type :: :away | :home

  @type t :: %__MODULE__{
          team_type: team_type() | :none,
          player_id: String.t(),
          state: state()
        }
  defstruct [:team_type, :player_id, :state]

  @spec new(team_type(), String.t(), state()) :: t()
  def new(team_type \\ :none, player_id, state \\ :no_protest) do
    %__MODULE__{
      team_type: team_type,
      player_id: player_id,
      state: state
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.ProtestState do
    def decode(
          %{
            team_type: team_type,
            player_id: player_id,
            state: state
          },
          _options
        ) do
      %GoChampsScoreboard.Games.Models.ProtestState{
        team_type: if(is_nil(team_type), do: :none, else: String.to_atom(team_type)),
        player_id: player_id,
        state: if(is_nil(state), do: :no_protest, else: String.to_atom(state))
      }
    end
  end
end
