defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager do
  @spec find_player(FibaScoresheet.Team.t(), String.t()) :: FibaScoresheet.Player.t() | nil
  def find_player(team, player_id) do
    Enum.find(team.players, fn player -> player.id == player_id end)
  end
end
