defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateTeamStatProcessor do
  @moduledoc """
  Processes team statistics updates in the FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  @regular_quarter_minutes 10
  @overtime_minutes 5

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

  def process_stat_by_category(team, "timeouts", event_log) do
    process_timeout_stat(team, event_log)
  end

  def process_stat_by_category(team, "lost_timeouts", event_log) do
    process_lost_timeout_stat(team, event_log)
  end

  def process_stat_by_category(team, _stat_id, _event_log), do: team

  def process_timeout_stat(team, event_log) do
    period = event_log.game_clock_period

    one_minute_in_seconds = 60

    period_initial_minutes = get_period_minutes(period)

    elapsed_minute =
      period_initial_minutes - div(event_log.game_clock_time, one_minute_in_seconds)

    timeout = %FibaScoresheet.Timeout{
      period: period,
      minute: elapsed_minute,
      lost: false
    }

    team
    |> TeamManager.add_timeout(timeout)
  end

  def process_lost_timeout_stat(team, event_log) do
    period = event_log.game_clock_period

    one_minute_in_seconds = 60

    period_initial_minutes = get_period_minutes(period)

    elapsed_minute =
      period_initial_minutes - div(event_log.game_clock_time, one_minute_in_seconds)

    timeout = %FibaScoresheet.Timeout{
      period: period,
      minute: elapsed_minute,
      lost: true
    }

    team
    |> TeamManager.add_timeout(timeout)
  end

  @doc """
  Returns the initial minutes for a given period
  """
  @spec get_period_minutes(integer()) :: integer()
  def get_period_minutes(period) when period in 1..4, do: @regular_quarter_minutes
  def get_period_minutes(_period), do: @overtime_minutes
end
