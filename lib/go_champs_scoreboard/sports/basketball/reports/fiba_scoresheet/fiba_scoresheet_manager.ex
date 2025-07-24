defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager do
  @moduledoc """
  FibaScoresheetManager module for FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.OfficialManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.Models.GameState

  @doc """
  Bootstraps the FIBA scoresheet data structure with initial values.
  """
  @spec bootstrap(EventLog.t()) :: FibaScoresheet.t()
  def bootstrap(event_log) do
    %FibaScoresheet{
      game_id: event_log.game_id,
      info: bootstrap_info(event_log.snapshot.state),
      team_a: TeamManager.bootstrap(event_log.snapshot.state.home_team),
      team_b: TeamManager.bootstrap(event_log.snapshot.state.away_team),
      scorer: OfficialManager.bootstrap(event_log.snapshot.state, :scorer),
      assistant_scorer: OfficialManager.bootstrap(event_log.snapshot.state, :assistant_scorer),
      timekeeper: OfficialManager.bootstrap(event_log.snapshot.state, :timekeeper),
      shot_clock_operator:
        OfficialManager.bootstrap(event_log.snapshot.state, :shot_clock_operator),
      crew_chief: OfficialManager.bootstrap(event_log.snapshot.state, :crew_chief),
      umpire_1: OfficialManager.bootstrap(event_log.snapshot.state, :umpire_1),
      umpire_2: OfficialManager.bootstrap(event_log.snapshot.state, :umpire_2)
    }
  end

  @spec bootstrap_info(GameState.t()) :: FibaScoresheet.Info.t()
  defp bootstrap_info(game_state) do
    %FibaScoresheet.Info{
      game_id: game_state.id,
      location: game_state.info.location,
      datetime: game_state.info.datetime,
      tournament_name: game_state.info.tournament_name,
      actual_start_datetime: game_state.clock_state.started_at,
      actual_end_datetime: game_state.clock_state.finished_at
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
