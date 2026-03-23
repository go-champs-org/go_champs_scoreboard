defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.FibaBoxScoreManager do
  @moduledoc """
  FibaBoxScore module for FIBA boxscore.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.{Team, Player}
  alias GoChampsScoreboard.Sports.Basketball.Reports.UrlHelper
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
      tournament_logo_url: UrlHelper.extract_path_from_url(state.info.tournament_logo_url),
      organization_name: state.info.organization_name,
      organization_logo_url: UrlHelper.extract_path_from_url(state.info.organization_logo_url),
      web_url: state.info.web_url,
      sponsors: map_sponsors(state.info.sponsors),
      home_team: bootstrap_team(state.home_team),
      away_team: bootstrap_team(state.away_team)
    }
  end

  @spec map_sponsors(list()) :: list()
  defp map_sponsors(sponsors) when is_list(sponsors) do
    Enum.map(sponsors, fn sponsor ->
      %{
        name: Map.get(sponsor, :name) || Map.get(sponsor, "name", ""),
        link: Map.get(sponsor, :link) || Map.get(sponsor, "link", ""),
        logo_url:
          UrlHelper.extract_path_from_url(
            Map.get(sponsor, :logo_url) || Map.get(sponsor, "logo_url", "")
          )
      }
    end)
  end

  defp map_sponsors(_), do: []

  @spec bootstrap_team(TeamState.t()) :: FibaBoxScore.Team.t()
  def bootstrap_team(team_state) do
    players = Enum.map(team_state.players, &bootstrap_player/1)

    %Team{
      name: team_state.name,
      points_by_period: %{},
      total_points: 0,
      total_player_stats: %{},
      players: players
    }
  end

  @spec bootstrap_player(PlayerState.t()) :: FibaBoxScore.Player.t()
  def bootstrap_player(player_state) do
    minutes_played = Map.get(player_state.stats_values, "minutes_played", 0)
    plus_minus = Map.get(player_state.stats_values, "plus_minus", 0)

    %Player{
      id: player_state.id,
      name: player_state.name,
      number: player_state.number,
      stats_values: %{
        "assists" => 0,
        "blocks" => 0,
        "steals" => 0,
        "turnovers" => 0,
        "field_goals_made" => 0,
        "field_goals_missed" => 0,
        "field_goals_attempted" => 0,
        "free_throws_made" => 0,
        "free_throws_missed" => 0,
        "free_throws_attempted" => 0,
        "three_point_field_goals_made" => 0,
        "three_point_field_goals_missed" => 0,
        "three_point_field_goals_attempted" => 0,
        "rebounds_defensive" => 0,
        "rebounds_offensive" => 0,
        "rebounds" => 0,
        "fouls_personal" => 0,
        "fouls_technical" => 0,
        "fouls_flagrant" => 0,
        "fouls_disqualifying" => 0,
        "fouls_disqualifying_fighting" => 0,
        "fouls_unsportsmanlike" => 0,
        "fouls" => 0,
        "points" => 0,
        "efficiency" => 0,
        "minutes_played" => minutes_played,
        "plus_minus" => plus_minus
      }
    }
  end

  @doc """
  Finds a team in the FibaBoxScore data structure by team type.
  """
  @spec find_team(FibaBoxScore.t(), String.t()) :: FibaBoxScore.Team.t()
  def find_team(data, "home"), do: data.home_team
  def find_team(data, "away"), do: data.away_team

  @doc """
  Updates a team in the FibaBoxScore data structure.
  """
  @spec update_team(FibaBoxScore.t(), String.t(), FibaBoxScore.Team.t()) :: FibaBoxScore.t()
  def update_team(data, "home", team), do: %{data | home_team: team}
  def update_team(data, "away", team), do: %{data | away_team: team}

  @doc """
  Finalizes the FibaBoxScore by summing player stats into team totals.
  """
  @spec finalize(FibaBoxScore.t()) :: FibaBoxScore.t()
  def finalize(fiba_box_score) do
    home_team = finalize_team(fiba_box_score.home_team)
    away_team = finalize_team(fiba_box_score.away_team)
    %{fiba_box_score | home_team: home_team, away_team: away_team}
  end

  defp finalize_team(team) do
    total_player_stats =
      Enum.reduce(team.players, %{}, fn player, acc ->
        Map.merge(acc, player.stats_values, fn _key, v1, v2 -> v1 + v2 end)
      end)

    total_points = Map.get(total_player_stats, "points", 0)
    %{team | total_player_stats: total_player_stats, total_points: total_points}
  end
end
