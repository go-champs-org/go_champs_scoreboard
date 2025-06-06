defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager do
  @moduledoc """
  FibaScoresheetManager module for FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  @doc """
  Bootstraps the FIBA scoresheet data structure with initial values.
  """
  @spec bootstrap(EventLog.t()) :: FibaScoresheet.t()
  def bootstrap(event_log) do
    %FibaScoresheet{
      game_id: event_log.game_id,
      tournament_name: "",
      header: %FibaScoresheet.Header{},
      team_a: TeamManager.bootstrap(event_log.snapshot.state.home_team),
      team_b: TeamManager.bootstrap(event_log.snapshot.state.away_team)
    }
  end

  @doc """
  Finds a team by its type (home or away).
  """
  @spec find_team(FibaScoresheet.t(), String.t()) :: FibaScoresheet.Team.t() | nil
  def find_team(fiba_scoresheet, team_type) do
    case team_type do
      "home" -> fiba_scoresheet.team_a
      "away" -> fiba_scoresheet.team_b
      _ -> nil
    end
  end

  @doc """
  Updates the FIBA scoresheet team.
  """
  @spec update_team(FibaScoresheet.t(), String.t(), FibaScoresheet.Team.t()) :: FibaScoresheet.t()
  def update_team(fiba_scoresheet, team_type, updated_team) do
    case team_type do
      "home" -> %{fiba_scoresheet | team_a: updated_team}
      "away" -> %{fiba_scoresheet | team_b: updated_team}
      _ -> fiba_scoresheet
    end
  end
end
