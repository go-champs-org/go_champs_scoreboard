defmodule GoChampsScoreboard.Sports.Basketball.PlayerState do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Players

  @spec update_player_state(PlayerState.t()) :: PlayerState.t()
  def update_player_state(player) do
    fouls = Map.get(player.stats_values, "fouls", 0)
    game_disqualifying_fouls = Map.get(player.stats_values, "fouls_game_disqualifying", 0)

    if (fouls >= 5 or game_disqualifying_fouls >= 1) and player.state != :disqualified do
      Players.update_state(player, :disqualified)
    else
      player
    end
  end
end
