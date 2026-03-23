defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.UpdatePlayerStatProcessor do
  @moduledoc """
  Processes player statistics update events for the FIBA boxscore report.
  Accumulates stats from events rather than reading from snapshot.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.FibaBoxScoreManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  alias GoChampsScoreboard.Sports.Basketball.Statistics
  alias GoChampsScoreboard.Events.EventLog

  @tracked_stats [
    "assists",
    "blocks",
    "steals",
    "turnovers",
    "field_goals_made",
    "field_goals_missed",
    "free_throws_made",
    "free_throws_missed",
    "three_point_field_goals_made",
    "three_point_field_goals_missed",
    "rebounds_defensive",
    "rebounds_offensive",
    "fouls_personal",
    "fouls_technical",
    "fouls_flagrant",
    "fouls_disqualifying",
    "fouls_disqualifying_fighting",
    "fouls_unsportsmanlike"
  ]

  @scoring_stats ["free_throws_made", "field_goals_made", "three_point_field_goals_made"]

  @spec process(EventLog.t(), FibaBoxScore.t()) :: FibaBoxScore.t()
  def process(event_log, data) do
    stat_id = event_log.payload["stat-id"]
    team_type = event_log.payload["team-type"]

    if stat_id in @tracked_stats do
      current_team = FibaBoxScoreManager.find_team(data, team_type)
      result_team = process_stat(current_team, stat_id, event_log)
      FibaBoxScoreManager.update_team(data, team_type, result_team)
    else
      data
    end
  end

  defp process_stat(team, stat_id, event_log) when stat_id in @scoring_stats do
    player_id = event_log.payload["player-id"]
    operation = event_log.payload["operation"]
    period = event_log.game_clock_period

    team
    |> update_player_stat(player_id, stat_id, operation)
    |> update_team_points_by_period(stat_id, operation, period)
  end

  defp process_stat(team, stat_id, event_log) do
    player_id = event_log.payload["player-id"]
    operation = event_log.payload["operation"]

    update_player_stat(team, player_id, stat_id, operation)
  end

  defp update_player_stat(team, player_id, stat_id, operation) do
    delta = if operation == "increment", do: 1, else: -1

    players =
      Enum.map(team.players, fn player ->
        if player.id == player_id do
          current_value = Map.get(player.stats_values, stat_id, 0)
          updated_stats = Map.put(player.stats_values, stat_id, current_value + delta)
          updated_player = %{player | stats_values: updated_stats}
          recalculate_derived_stats(updated_player)
        else
          player
        end
      end)

    %{team | players: players}
  end

  defp update_team_points_by_period(team, stat_id, operation, period) do
    points_delta =
      case stat_id do
        "free_throws_made" -> if operation == "increment", do: 1, else: -1
        "field_goals_made" -> if operation == "increment", do: 2, else: -2
        "three_point_field_goals_made" -> if operation == "increment", do: 3, else: -3
      end

    current = Map.get(team.points_by_period, period, 0)
    %{team | points_by_period: Map.put(team.points_by_period, period, current + points_delta)}
  end

  defp recalculate_derived_stats(player) do
    updated_stats =
      player.stats_values
      |> Map.put("points", Statistics.calc_player_points(player))
      |> Map.put("rebounds", Statistics.calc_player_rebounds(player))
      |> Map.put("fouls", Statistics.calc_player_fouls(player))
      |> Map.put("field_goals_attempted", Statistics.calc_player_field_goals_attempted(player))
      |> Map.put(
        "free_throws_attempted",
        Statistics.calc_player_free_throws_attempted(player)
      )
      |> Map.put(
        "three_point_field_goals_attempted",
        Statistics.calc_player_three_point_field_goals_attempted(player)
      )
      |> Map.put("efficiency", Statistics.calc_player_efficiency(player))

    %{player | stats_values: updated_stats}
  end
end
