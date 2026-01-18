defmodule GoChampsScoreboard.Sports.Basketball.Statistics do
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.GameState

  @spec calc_player_efficiency(PlayerState.t()) :: float()
  def calc_player_efficiency(player_state) do
    points = calc_player_points(player_state)
    rebounds = calc_player_rebounds(player_state)
    assists = Map.get(player_state.stats_values, "assists", 0)
    steals = Map.get(player_state.stats_values, "steals", 0)
    blocks = Map.get(player_state.stats_values, "blocks", 0)

    field_goals_missed =
      Map.get(player_state.stats_values, "field_goals_missed", 0)

    free_throws_missed =
      Map.get(player_state.stats_values, "free_throws_missed", 0)

    three_point_field_goals_missed =
      Map.get(player_state.stats_values, "three_point_field_goals_missed", 0)

    turnovers = Map.get(player_state.stats_values, "turnovers", 0)

    points + rebounds + assists + steals + blocks - field_goals_missed -
      free_throws_missed - three_point_field_goals_missed - turnovers
  end

  @spec calc_player_field_goal_percentage(PlayerState.t()) :: float()
  def calc_player_field_goal_percentage(player_state) do
    field_goals_made = Map.get(player_state.stats_values, "field_goals_made", 0)
    field_goals_missed = Map.get(player_state.stats_values, "field_goals_missed", 0)

    calc_percentage(field_goals_made, field_goals_missed)
  end

  @spec calc_player_field_goals_attempted(PlayerState.t()) :: float()
  def calc_player_field_goals_attempted(player_state) do
    field_goals_made = Map.get(player_state.stats_values, "field_goals_made", 0)
    field_goals_missed = Map.get(player_state.stats_values, "field_goals_missed", 0)

    field_goals_made + field_goals_missed
  end

  @spec calc_player_fouls(PlayerState.t()) :: float()
  def calc_player_fouls(player_state) do
    fouls_disqualifying = Map.get(player_state.stats_values, "fouls_disqualifying", 0)

    fouls_disqualifying_fighting =
      Map.get(player_state.stats_values, "fouls_disqualifying_fighting", 0)

    fouls_flagrant = Map.get(player_state.stats_values, "fouls_flagrant", 0)
    personal_fouls = Map.get(player_state.stats_values, "fouls_personal", 0)
    technical_fouls = Map.get(player_state.stats_values, "fouls_technical", 0)
    fouls_unsportsmanlike = Map.get(player_state.stats_values, "fouls_unsportsmanlike", 0)

    personal_fouls + technical_fouls + fouls_flagrant + fouls_disqualifying +
      fouls_disqualifying_fighting + fouls_unsportsmanlike
  end

  @spec calc_player_free_throw_percentage(PlayerState.t()) :: float()
  def calc_player_free_throw_percentage(player_state) do
    free_throws_made = Map.get(player_state.stats_values, "free_throws_made", 0)
    free_throws_missed = Map.get(player_state.stats_values, "free_throws_missed", 0)

    calc_percentage(free_throws_made, free_throws_missed)
  end

  @spec calc_player_free_throws_attempted(PlayerState.t()) :: float()
  def calc_player_free_throws_attempted(player_state) do
    free_throws_made = Map.get(player_state.stats_values, "free_throws_made", 0)
    free_throws_missed = Map.get(player_state.stats_values, "free_throws_missed", 0)

    free_throws_made + free_throws_missed
  end

  @spec calc_player_points(PlayerState.t()) :: float()
  def calc_player_points(player_state) do
    one_points_made = Map.get(player_state.stats_values, "free_throws_made", 0)
    two_points_made = Map.get(player_state.stats_values, "field_goals_made", 0)
    three_points_made = Map.get(player_state.stats_values, "three_point_field_goals_made", 0)

    1 * one_points_made + 2 * two_points_made + 3 * three_points_made
  end

  @spec calc_player_rebounds(PlayerState.t()) :: float()
  def calc_player_rebounds(player_state) do
    def_rebounds = Map.get(player_state.stats_values, "rebounds_defensive", 0)
    off_rebounds = Map.get(player_state.stats_values, "rebounds_offensive", 0)

    def_rebounds + off_rebounds
  end

  @spec calc_player_three_point_field_goal_percentage(PlayerState.t()) :: float()
  def calc_player_three_point_field_goal_percentage(player_state) do
    three_points_made = Map.get(player_state.stats_values, "three_point_field_goals_made", 0)
    three_points_missed = Map.get(player_state.stats_values, "three_point_field_goals_missed", 0)

    calc_percentage(three_points_made, three_points_missed)
  end

  @spec calc_player_three_point_field_goals_attempted(PlayerState.t()) :: float()
  def calc_player_three_point_field_goals_attempted(player_state) do
    three_points_made = Map.get(player_state.stats_values, "three_point_field_goals_made", 0)
    three_points_missed = Map.get(player_state.stats_values, "three_point_field_goals_missed", 0)

    three_points_made + three_points_missed
  end

  @spec calc_team_points(TeamState.t()) :: float()
  def calc_team_points(team_state) do
    if Map.get(team_state.stats_values, "game_walkover_against", 0) == 1 do
      20
    else
      Map.get(team_state.total_player_stats, "points", 0)
    end
  end

  @spec calc_team_fouls(TeamState.t()) :: float()
  def calc_team_fouls(team_state) do
    fouls_disqualifying = Map.get(team_state.total_player_stats, "fouls_disqualifying", 0)
    fouls_flagrant = Map.get(team_state.total_player_stats, "fouls_flagrant", 0)
    fouls_personal = Map.get(team_state.total_player_stats, "fouls_personal", 0)
    fouls_technical = Map.get(team_state.total_player_stats, "fouls_technical", 0)
    fouls_unsportsmanlike = Map.get(team_state.total_player_stats, "fouls_unsportsmanlike", 0)

    fouls_disqualifying + fouls_flagrant + fouls_personal + fouls_technical +
      fouls_unsportsmanlike
  end

  @spec calc_team_technical_fouls(TeamState.t()) :: float()
  def calc_team_technical_fouls(team_state) do
    total_technical_fouls_players = Map.get(team_state.total_player_stats, "fouls_technical", 0)
    technical_fouls = Map.get(team_state.stats_values, "fouls_technical", 0)

    total_technical_fouls_players + technical_fouls
  end

  @spec calc_coach_fouls(CoachState.t()) :: float()
  def calc_coach_fouls(coach_state) do
    fouls_technical = Map.get(coach_state.stats_values, "fouls_technical", 0)
    fouls_disqualifying = Map.get(coach_state.stats_values, "fouls_disqualifying", 0)
    fouls_game_disqualifying = Map.get(coach_state.stats_values, "fouls_game_disqualifying", 0)
    fouls_technical_bench = Map.get(coach_state.stats_values, "fouls_technical_bench", 0)

    fouls_technical + fouls_disqualifying + fouls_game_disqualifying + fouls_technical_bench
  end

  defp calc_percentage(made, missed) do
    case made do
      0 -> 0
      _ -> (made / (made + missed) * 100) |> Float.round(3)
    end
  end

  @spec calc_player_plus_minus(
          PlayerState.t(),
          GameState.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t()
        ) :: float()
  def calc_player_plus_minus(
        player_state,
        _game_state,
        player_team_type,
        stat_id,
        operation,
        event_team_type
      ) do
    current_plus_minus = Map.get(player_state.stats_values, "plus_minus", 0)

    player_state_value = Map.get(player_state, :state, :bench)

    if player_state_value != :playing do
      current_plus_minus
    else
      points =
        case stat_id do
          "free_throws_made" -> 1
          "field_goals_made" -> 2
          "three_point_field_goals_made" -> 3
          _ -> 0
        end

      points =
        case operation do
          "increment" -> points
          "decrement" -> -points
          _ -> 0
        end

      delta =
        if event_team_type == player_team_type do
          points
        else
          -points
        end

      current_plus_minus + delta
    end
  end
end
