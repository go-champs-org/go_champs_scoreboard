defmodule GoChampsScoreboard.Games.Models.TeamState do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type t :: %__MODULE__{
          name: String.t(),
          players: list(PlayerState.t()),
          total_player_stats: map(),
          stats_values: map(),
          tri_code: String.t(),
          logo_url: String.t()
        }
  defstruct [:name, :players, :total_player_stats, :stats_values, :tri_code, :logo_url]

  @spec new(String.t(), list(PlayerState.t()), map()) :: t()
  def new(
        name,
        players \\ [],
        total_player_stats \\ %{},
        stats_values \\ Basketball.bootstrap_team_stats(),
        tri_code \\ "",
        logo_url \\ ""
      ) do
    %__MODULE__{
      name: name,
      players: players,
      total_player_stats: total_player_stats,
      stats_values: stats_values,
      tri_code: tri_code,
      logo_url: logo_url
    }
  end
end
