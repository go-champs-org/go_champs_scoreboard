defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor do
  @moduledoc """
  Processes player statistics updates in the FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  # Scoring stats that need point score entries
  @scoring_stats ["free_throws_made", "three_point_field_goals_made", "field_goals_made"]

  # Non-scoring stats that need special handling
  @foul_stats [
    "fouls_personal",
    "fouls_technical",
    "fouls_unsportsmanlike",
    "fouls_disqualifying"
  ]

  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    stat_id = event_log.payload["stat-id"]
    team_type = event_log.payload["team-type"]

    current_team =
      FibaScoresheetManager.find_team(data, team_type)

    result_team =
      process_stat_by_category(current_team, stat_id, event_log)

    data
    |> FibaScoresheetManager.update_team(team_type, result_team)
  end

  @doc """
  Routes the processing to the appropriate function based on stat category.
  """
  @spec process_stat_by_category(FibaScoresheet.Team.t(), String.t(), EventLog.t()) ::
          FibaScoresheet.Team.t()
  def process_stat_by_category(team, stat_id, event_log) when stat_id in @scoring_stats do
    process_scoring_stat(team, event_log)
  end

  def process_stat_by_category(team, stat_id, event_log) when stat_id in @foul_stats do
    process_foul_stat(team, stat_id, event_log)
  end

  # Default handler for any other stat
  def process_stat_by_category(team, _stat_id, _event_log), do: team

  def process_scoring_stat(team, event_log) do
    player_id = event_log.payload["player-id"]
    stat_id = event_log.payload["stat-id"]

    player =
      team
      |> PlayerManager.find_player(player_id)

    point_score_type =
      case stat_id do
        "free_throws_made" -> "FT"
        "field_goals_made" -> "2PT"
        "three_point_field_goals_made" -> "3PT"
      end

    point_score = %FibaScoresheet.PointScore{
      type: point_score_type,
      player_number: player.number,
      period: event_log.game_clock_period,
      is_last_of_period: false
    }

    team
    |> TeamManager.add_score(point_score)
  end

  def process_foul_stat(team, stat_id, event_log) do
    player_id = event_log.payload["player-id"]

    foul_type =
      case stat_id do
        "fouls_personal" -> "P"
      end

    foul = %FibaScoresheet.Foul{
      type: foul_type,
      period: event_log.game_clock_period,
      extra_action: nil
    }

    team
    |> TeamManager.add_player_foul(player_id, foul)
  end
end
