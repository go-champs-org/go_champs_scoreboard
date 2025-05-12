defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager do
  def find_player(team, player_id) do
    Enum.find(team.players, fn player -> player.id == player_id end)
  end
end
