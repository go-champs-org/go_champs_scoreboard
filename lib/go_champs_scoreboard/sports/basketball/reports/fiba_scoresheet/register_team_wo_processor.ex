defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.RegisterTeamWoProcessor do
  @moduledoc """
  Handles the processing of register team walkover events in FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  @doc """
  Processes the register of a team walkover event.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    team_type = Map.get(event_log.payload, "team-type")

    case team_type do
      "home" ->
        updated_home =
          FibaScoresheetManager.find_team(data, "home")
          |> TeamManager.set_losing_wo()

        updated_away =
          FibaScoresheetManager.find_team(data, "away")
          |> TeamManager.set_winning_wo()
          |> TeamManager.set_players_starters(event_log.snapshot.state.away_team)

        data
        |> FibaScoresheetManager.update_team("home", updated_home)
        |> FibaScoresheetManager.update_team("away", updated_away)

      "away" ->
        updated_away =
          FibaScoresheetManager.find_team(data, "away")
          |> TeamManager.set_losing_wo()

        updated_home =
          FibaScoresheetManager.find_team(data, "home")
          |> TeamManager.set_winning_wo()
          |> TeamManager.set_players_starters(event_log.snapshot.state.home_team)

        data
        |> FibaScoresheetManager.update_team("away", updated_away)
        |> FibaScoresheetManager.update_team("home", updated_home)

      _ ->
        data
    end
  end
end
