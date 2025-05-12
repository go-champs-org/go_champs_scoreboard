defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.SubstitutePlayerProcessor do
  @moduledoc """
  Handles the processing of substitute player events in FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager

  @doc """
  Processes the substitute player event and updates the FIBA scoresheet.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    team_type = event_log.payload["team-type"]
    playing_player_id = event_log.payload["playing-player-id"]
    bench_player_id = event_log.payload["bench-player-id"]

    current_team =
      FibaScoresheetManager.find_team(data, team_type)

    result_team =
      current_team
      |> PlayerManager.find_player(bench_player_id)
      |> update_substitute_player(playing_player_id)
      |> TeamManager.update_player(current_team)

    data
    |> FibaScoresheetManager.update_team(team_type, result_team)
  end

  defp update_substitute_player(player, nil) do
    player
    |> Map.put(:has_played, true)
    |> Map.put(:has_started, true)
  end

  defp update_substitute_player(player, _bench_player_id) do
    player
    |> Map.put(:has_played, true)
  end
end
