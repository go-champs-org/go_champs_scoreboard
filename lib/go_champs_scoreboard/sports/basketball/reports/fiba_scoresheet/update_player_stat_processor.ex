defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor do
  @moduledoc """
  Processes player statistics updates in the FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    player_id = event_log.payload["player-id"]
    team_type = event_log.payload["team-type"]
    stat_id = event_log.payload["stat-id"]

    current_team =
      FibaScoresheetManager.find_team(data, team_type)

    player =
      PlayerManager.find_player(current_team, player_id)

    point_score_type =
      case stat_id do
        "free_throws_made" -> "FT"
        "field_goals_made" -> "2PT"
        "three_point_field_goals_made" -> "3PT"
      end

    point_score = %FibaScoresheet.PointScore{
      type: point_score_type,
      player_number: player.number,
      is_last_of_quarter: false
    }

    result_team =
      current_team
      |> TeamManager.add_score(point_score)

    data
    |> FibaScoresheetManager.update_team(team_type, result_team)
  end
end
