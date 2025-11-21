defmodule GoChampsScoreboard.Games.Models.TeamState do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type t :: %__MODULE__{
          name: String.t(),
          players: list(PlayerState.t()),
          coaches: list(CoachState.t()),
          total_player_stats: map(),
          stats_values: map(),
          tri_code: String.t(),
          logo_url: String.t(),
          period_stats: map()
        }
  defstruct [
    :name,
    :players,
    :coaches,
    :total_player_stats,
    :stats_values,
    :tri_code,
    :logo_url,
    :period_stats
  ]

  @spec new(String.t(), list(PlayerState.t()), map()) :: t()
  def new(
        name,
        players \\ [],
        total_player_stats \\ %{},
        stats_values \\ nil,
        tri_code \\ "",
        logo_url \\ "",
        coaches \\ []
      ) do
    final_stats_values =
      if is_nil(stats_values), do: Basketball.bootstrap_team_stats(), else: stats_values

    %__MODULE__{
      name: name,
      players: players,
      coaches: coaches,
      total_player_stats: total_player_stats,
      stats_values: final_stats_values,
      tri_code: tri_code,
      logo_url: logo_url,
      period_stats: %{}
    }
  end
end
