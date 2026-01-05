defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.FibaBoxScoreManager do
  @moduledoc """
  FibaBoxScore module for FIBA boxscore.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.{Team, Player}
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.PlayerState

  @doc """
  Bootstraps the FIBA boxscore data structure with initial values.
  """
  @spec bootstrap(EventLog.t()) :: FibaBoxScore.t()
  def bootstrap(event_log) do
    state = event_log.snapshot.state

    %FibaBoxScore{
      number: state.info.number,
      location: state.info.location,
      datetime: state.info.datetime,
      actual_start_datetime: state.clock_state.started_at,
      actual_end_datetime: state.clock_state.finished_at,
      tournament_name: state.info.tournament_name,
      organization_name: state.info.organization_name,
      organization_logo_url: state.info.organization_logo_url,
      web_url: state.info.web_url,
      home_team: bootstrap_team(state.home_team),
      away_team: bootstrap_team(state.away_team)
    }
  end

  @spec bootstrap_team(TeamState.t()) :: FibaBoxScore.Team.t()
  def bootstrap_team(team_state) do
    players = Enum.map(team_state.players, &bootstrap_player/1)

    %Team{
      name: team_state.name,
      points_by_period: map_points_by_period(team_state.period_stats),
      total_points: team_state.total_player_stats["points"] || 0,
      total_player_stats: team_state.total_player_stats,
      players: players
    }
  end

  @spec bootstrap_player(PlayerState.t()) :: FibaBoxScore.Player.t()
  def bootstrap_player(player_state) do
    %Player{
      id: player_state.id,
      name: player_state.name,
      number: player_state.number,
      stats_values: player_state.stats_values
    }
  end

  defp map_points_by_period(period_stats) do
    period_stats
    |> Enum.map(fn {period, stats} -> {period, Map.get(stats, "points", 0)} end)
    |> Enum.into(%{})
  end
end
