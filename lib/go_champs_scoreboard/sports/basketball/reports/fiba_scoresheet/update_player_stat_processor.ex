defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor do
  @moduledoc """
  Processes player statistics updates in the FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  # Scoring stats that need point score entries
  @scoring_stats ["free_throws_made", "three_point_field_goals_made", "field_goals_made"]

  # Non-scoring stats that need special handling
  @foul_stats [
    "fouls_personal",
    "fouls_technical",
    "fouls_unsportsmanlike",
    "fouls_disqualifying",
    "fouls_disqualifying_fighting",
    "fouls_game_disqualifying"
  ]

  # GD foul triggering rules
  @gd_triggering_fouls ["T", "U"]
  @max_technical_fouls 2
  @max_unsportsmanlike_fouls 2
  @disqualifying_combination_limit 1

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

  @doc """
  Routes the processing to the appropriate function based on stat category.
  """
  @spec process_stat_by_category(FibaScoresheet.Team.t(), String.t(), EventLog.t()) ::
          FibaScoresheet.Team.t()
  def process_stat_by_category(team, stat_id, event_log) when stat_id in @scoring_stats do
    process_scoring_stat(team, event_log)
  end

  def process_stat_by_category(team, stat_id, event_log) when stat_id in @foul_stats do
    process_foul_stat(team, stat_id, event_log)
  end

  # Default handler for any other stat
  def process_stat_by_category(team, _stat_id, _event_log), do: team

  def process_scoring_stat(team, event_log) do
    player_id = event_log.payload["player-id"]
    stat_id = event_log.payload["stat-id"]

    player =
      team
      |> PlayerManager.find_player(player_id)

    # Skip processing if player not found
    if is_nil(player) do
      team
    else
      point_score_type =
        case stat_id do
          "free_throws_made" -> "FT"
          "field_goals_made" -> "2PT"
          "three_point_field_goals_made" -> "3PT"
        end

      point_score = %FibaScoresheet.PointScore{
        type: point_score_type,
        player_number: player.number,
        period: event_log.game_clock_period,
        is_last_of_period: false
      }

      team
      |> TeamManager.add_score(point_score)
      |> TeamManager.add_points_to_period(
        event_log.game_clock_period,
        TeamManager.points_for_score_type(point_score_type)
      )
    end
  end

  def process_foul_stat(team, stat_id, event_log) do
    player_id = event_log.payload["player-id"]

    # Skip processing if player not found
    player = PlayerManager.find_player(team, player_id)

    if is_nil(player) do
      team
    else
      foul_type =
        case stat_id do
          "fouls_personal" -> "P"
          "fouls_technical" -> "T"
          "fouls_unsportsmanlike" -> "U"
          "fouls_disqualifying" -> "D"
          "fouls_disqualifying_fighting" -> "F"
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

      # Add the foul to the team
      team_with_foul = TeamManager.add_player_foul(team, player_id, foul)

      # Get updated player and check if we need to automatically add a GD foul
      updated_player = PlayerManager.find_player(team_with_foul, player_id)

      # Handle special F foul logic
      team_after_gd = check_and_add_gd_foul(team_with_foul, updated_player, foul_type, event_log)

      # Handle F foul special processing
      updated_player_after_gd = PlayerManager.find_player(team_after_gd, player_id)
      handle_fighting_foul_logic(team_after_gd, updated_player_after_gd, foul_type, event_log)
    end
  end

  # Private helper functions for GD foul logic

  defp count_fouls_by_type(fouls, foul_type) do
    Enum.count(fouls, fn foul -> foul.type == foul_type end)
  end

  defp get_foul_counts(player) do
    t_count = count_fouls_by_type(player.fouls, "T")
    u_count = count_fouls_by_type(player.fouls, "U")
    {t_count, u_count}
  end

  defp qualifies_for_gd?({t_count, u_count}) do
    case {t_count, u_count} do
      {t, _} when t >= @max_technical_fouls ->
        true

      {_, u} when u >= @max_unsportsmanlike_fouls ->
        true

      {t, u}
      when t >= @disqualifying_combination_limit and u >= @disqualifying_combination_limit ->
        true

      _ ->
        false
    end
  end

  defp create_gd_foul(period) do
    %FibaScoresheet.Foul{
      type: "GD",
      period: period,
      extra_action: nil,
      is_last_of_half: false
    }
  end

  defp create_f_foul(period) do
    %FibaScoresheet.Foul{
      type: "F",
      period: period,
      extra_action: nil,
      is_last_of_half: false
    }
  end

  @doc """
  Handles special logic for F (fouls_disqualifying_fighting) fouls.
  Adds additional F fouls until player reaches exactly 5 total fouls.
  """
  @spec handle_fighting_foul_logic(
          FibaScoresheet.Team.t(),
          FibaScoresheet.Player.t() | nil,
          String.t(),
          EventLog.t()
        ) ::
          FibaScoresheet.Team.t()
  def handle_fighting_foul_logic(team, player, foul_type, event_log) do
    if foul_type == "F" and not is_nil(player) do
      total_fouls = length(player.fouls)

      if total_fouls < 5 do
        # Add additional F fouls to reach exactly 5
        additional_f_fouls_needed = 5 - total_fouls

        Enum.reduce(1..additional_f_fouls_needed, team, fn _, acc_team ->
          f_foul = create_f_foul(event_log.game_clock_period)
          TeamManager.add_player_foul(acc_team, player.id, f_foul)
        end)
      else
        # Player already has 5+ fouls, no additional F fouls needed
        team
      end
    else
      team
    end
  end

  @doc """
  Checks if a GD (Game Disqualifying) foul should be automatically added based on T and U foul accumulation.
  Adds GD foul if player has: 2 T fouls, 2 U fouls, or 1 T + 1 U foul.
  """
  @spec check_and_add_gd_foul(
          FibaScoresheet.Team.t(),
          FibaScoresheet.Player.t() | nil,
          String.t(),
          EventLog.t()
        ) ::
          FibaScoresheet.Team.t()
  def check_and_add_gd_foul(team, player, foul_type, event_log) do
    # Only check for GD after adding T or U fouls
    with true <- foul_type in @gd_triggering_fouls,
         %{} <- player,
         true <- player |> get_foul_counts() |> qualifies_for_gd?() do
      gd_foul = create_gd_foul(event_log.game_clock_period)
      TeamManager.add_player_foul(team, player.id, gd_foul)
    else
      _ -> team
    end
  end
end
