defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessor do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Events.EventLog

  # Non-scoring stats that need special handling
  @foul_stats [
    "fouls_technical",
    "fouls_disqualifying",
    "fouls_disqualifying_fighting",
    "fouls_technical_bench",
    "fouls_technical_bench_disqualifying",
    "fouls_game_disqualifying"
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

  def process_stat_by_category(team, stat_id, event_log) when stat_id in @foul_stats do
    process_foul_stat(team, stat_id, event_log)
  end

  # Default handler for any other stat
  def process_stat_by_category(team, _stat_id, _event_log), do: team

  def process_foul_stat(team, stat_id, event_log) do
    coach_id = event_log.payload["coach-id"]

    foul_type =
      case stat_id do
        "fouls_technical" -> "C"
        "fouls_disqualifying" -> "D"
        "fouls_disqualifying_fighting" -> "F"
        "fouls_technical_bench" -> "B"
        "fouls_technical_bench_disqualifying" -> "BD"
        "fouls_game_disqualifying" -> "GD"
      end

    # Extract extra_action from metadata if present
    extra_action =
      case get_in(event_log.payload, ["metadata", "free-throws-awarded"]) do
        nil -> nil
        value -> value
      end

    foul = %FibaScoresheet.Foul{
      type: foul_type,
      period: event_log.game_clock_period,
      extra_action: extra_action,
      is_last_of_half: false
    }

    team
    |> TeamManager.add_coach_foul(coach_id, foul)
  end
end
