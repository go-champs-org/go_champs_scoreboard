defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateClockStateProcessor do
  @moduledoc """
  Handles the processing of update clock state events in FIBA scoresheet.
  Marks players as having started when the game begins.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager

  @doc """
  Processes the update clock state event and updates the FIBA scoresheet.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    game_clock_time = event_log.game_clock_time
    game_clock_period = event_log.game_clock_period
    initial_period_time = data.info.initial_period_time
    state = event_log.payload["state"]

    if game_clock_time == initial_period_time and game_clock_period == 1 and state == "running" do
      data
      |> FibaScoresheetManager.update_team(
        "home",
        FibaScoresheetManager.find_team(data, "home")
        |> TeamManager.set_players_starters(event_log.snapshot.state.home_team)
      )
      |> FibaScoresheetManager.update_team(
        "away",
        FibaScoresheetManager.find_team(data, "away")
        |> TeamManager.set_players_starters(event_log.snapshot.state.away_team)
      )
    else
      data
    end
  end
end
