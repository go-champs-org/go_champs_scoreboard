defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager do
  @moduledoc """
  Manages player-related operations within the FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  @spec find_player(FibaScoresheet.Team.t(), String.t()) :: FibaScoresheet.Player.t() | nil
  def find_player(team, player_id) do
    Enum.find(team.players, fn player -> player.id == player_id end)
  end

  @spec set_as_starter(FibaScoresheet.Player.t()) :: FibaScoresheet.Player.t()
  def set_as_starter(player) do
    player
    |> Map.put(:has_played, true)
    |> Map.put(:has_started, true)
    |> Map.put(:first_played_period, 1)
  end
end
