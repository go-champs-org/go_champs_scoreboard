defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessor do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.CoachManager
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

  @fiba_2026_foul_stats [
    "fouls_technical",
    "fouls_disqualifying",
    "fouls_disqualifying_fighting",
    "fouls_technical_bench",
    "fouls_technical_bench_disqualifying",
    "fouls_technical_bench_disqualifying_circled",
    "fouls_game_disqualifying"
  ]

  # Bench members disqualified in the same incident with a single BD event
  @max_disqualified_members 2

  # GD foul triggering conditions
  @gd_triggering_fouls ["C", "B"]
  @max_technical_fouls 2
  @max_technical_bench_fouls 3
  @disqualifying_combination_limit 1

  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    stat_id = event_log.payload["stat-id"]
    team_type = event_log.payload["team-type"]

    current_team =
      FibaScoresheetManager.find_team(data, team_type)

    result_team =
      process_stat_by_category(current_team, stat_id, event_log, rules_version(data))

    data
    |> FibaScoresheetManager.update_team(team_type, result_team)
  end

  def process_stat_by_category(team, stat_id, event_log, rules_version \\ "fiba-2024")

  def process_stat_by_category(team, stat_id, event_log, "fiba-2026")
      when stat_id in @fiba_2026_foul_stats do
    process_fiba_2026_foul_stat(team, stat_id, event_log)
  end

  def process_stat_by_category(team, stat_id, event_log, _rules_version)
      when stat_id in @foul_stats do
    process_foul_stat(team, stat_id, event_log)
  end

  # Default handler for any other stat
  def process_stat_by_category(team, _stat_id, _event_log, _rules_version), do: team

  def process_foul_stat(team, stat_id, event_log) do
    coach_id = event_log.payload["coach-id"]

    # Skip processing if coach not found
    coach = CoachManager.find_coach(team, coach_id)

    if is_nil(coach) do
      team
    else
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

      # Add the foul to the team
      team_with_foul = TeamManager.add_coach_foul(team, coach_id, foul)

      # Get updated coach and check if we need to automatically add a GD foul
      updated_coach = CoachManager.find_coach(team_with_foul, coach_id)

      # Handle automatic GD foul logic
      team_after_gd = check_and_add_gd_foul(team_with_foul, updated_coach, foul_type, event_log)

      # Handle F foul special processing
      updated_coach_after_gd = CoachManager.find_coach(team_after_gd, coach_id)
      handle_fighting_foul_logic(team_after_gd, updated_coach_after_gd, foul_type, event_log)
    end
  end

  @doc """
  Processes a coach foul under the FIBA 2026 rules.
  C, B and the circled BD are circled and count toward the GD. The BD without circle
  adds one entry per disqualified bench member of the incident.
  """
  @spec process_fiba_2026_foul_stat(FibaScoresheet.Team.t(), String.t(), EventLog.t()) ::
          FibaScoresheet.Team.t()
  def process_fiba_2026_foul_stat(team, stat_id, event_log) do
    coach_id = event_log.payload["coach-id"]

    # Skip processing if coach not found
    coach = CoachManager.find_coach(team, coach_id)

    if is_nil(coach) do
      team
    else
      {foul_type, is_circled} =
        case stat_id do
          "fouls_technical" -> {"C", true}
          "fouls_disqualifying" -> {"D", false}
          "fouls_disqualifying_fighting" -> {"F", false}
          "fouls_technical_bench" -> {"B", true}
          "fouls_technical_bench_disqualifying" -> {"BD", false}
          "fouls_technical_bench_disqualifying_circled" -> {"BD", true}
          "fouls_game_disqualifying" -> {"GD", false}
        end

      foul = %FibaScoresheet.Foul{
        type: foul_type,
        period: event_log.game_clock_period,
        extra_action: get_in(event_log.payload, ["metadata", "free-throws-awarded"]),
        is_last_of_half: false,
        is_circled: is_circled
      }

      team_with_fouls =
        Enum.reduce(1..fouls_count(stat_id, event_log), team, fn _, acc_team ->
          TeamManager.add_coach_foul(acc_team, coach_id, foul)
        end)

      updated_coach = CoachManager.find_coach(team_with_fouls, coach_id)

      team_after_gd =
        check_and_add_fiba_2026_gd_foul(team_with_fouls, updated_coach, foul, event_log)

      updated_coach_after_gd = CoachManager.find_coach(team_after_gd, coach_id)
      handle_fighting_foul_logic(team_after_gd, updated_coach_after_gd, foul_type, event_log)
    end
  end

  defp fouls_count("fouls_technical_bench_disqualifying", event_log) do
    case get_in(event_log.payload, ["metadata", "disqualified-members"]) do
      members when members in [@max_disqualified_members, "2"] -> @max_disqualified_members
      _ -> 1
    end
  end

  defp fouls_count(_stat_id, _event_log), do: 1

  defp check_and_add_fiba_2026_gd_foul(team, coach, foul, event_log) do
    with true <- foul.is_circled,
         %{} <- coach,
         true <- coach |> get_fiba_2026_foul_counts() |> qualifies_for_gd?() do
      gd_foul = create_gd_foul(event_log.game_clock_period)
      TeamManager.add_coach_foul(team, coach.id, gd_foul)
    else
      _ -> team
    end
  end

  # FIBA 2026: the circled BD counts together with the B fouls
  defp get_fiba_2026_foul_counts(coach) do
    circled_fouls = Enum.filter(coach.fouls, & &1.is_circled)
    c_count = count_fouls_by_type(circled_fouls, "C")
    b_count = Enum.count(circled_fouls, &(&1.type in ["B", "BD"]))
    {c_count, b_count}
  end

  defp rules_version(%FibaScoresheet{info: %FibaScoresheet.Info{rules_version: rules_version}})
       when is_binary(rules_version),
       do: rules_version

  defp rules_version(_data), do: "fiba-2024"

  # Private helper functions for GD foul logic

  defp count_fouls_by_type(fouls, foul_type) do
    Enum.count(fouls, fn foul -> foul.type == foul_type end)
  end

  defp get_foul_counts(coach) do
    c_count = count_fouls_by_type(coach.fouls, "C")
    b_count = count_fouls_by_type(coach.fouls, "B")
    {c_count, b_count}
  end

  defp qualifies_for_gd?({c_count, b_count}) do
    case {c_count, b_count} do
      {c, _} when c >= @max_technical_fouls ->
        true

      {_, b} when b >= @max_technical_bench_fouls ->
        true

      {c, b}
      when c >= @disqualifying_combination_limit and b >= @max_technical_fouls ->
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
  Handles special logic for F (fouls_disqualifying_fighting) fouls for coaches.
  Adds additional F fouls until coach reaches exactly 3 total fouls.
  """
  @spec handle_fighting_foul_logic(
          FibaScoresheet.Team.t(),
          FibaScoresheet.Coach.t() | nil,
          String.t(),
          EventLog.t()
        ) ::
          FibaScoresheet.Team.t()
  def handle_fighting_foul_logic(team, coach, foul_type, event_log) do
    if foul_type == "F" and not is_nil(coach) do
      total_fouls = length(coach.fouls)

      if total_fouls < 3 do
        # Add additional F fouls to reach exactly 3
        additional_f_fouls_needed = 3 - total_fouls

        Enum.reduce(1..additional_f_fouls_needed, team, fn _, acc_team ->
          f_foul = create_f_foul(event_log.game_clock_period)
          TeamManager.add_coach_foul(acc_team, coach.id, f_foul)
        end)
      else
        # Coach already has 3+ fouls, no additional F fouls needed
        team
      end
    else
      team
    end
  end

  @doc """
  Checks if a GD (Game Disqualifying) foul should be automatically added based on C and B foul accumulation.
  Adds GD foul if coach has: 2 C fouls, 3 B fouls, or 1 C + 2 B fouls.
  """
  @spec check_and_add_gd_foul(
          FibaScoresheet.Team.t(),
          FibaScoresheet.Coach.t() | nil,
          String.t(),
          EventLog.t()
        ) ::
          FibaScoresheet.Team.t()
  def check_and_add_gd_foul(team, coach, foul_type, event_log) do
    # Only check for GD after adding C or B fouls
    if foul_type in @gd_triggering_fouls and not is_nil(coach) do
      if coach |> get_foul_counts() |> qualifies_for_gd?() do
        gd_foul = create_gd_foul(event_log.game_clock_period)
        TeamManager.add_coach_foul(team, coach.id, gd_foul)
      else
        team
      end
    else
      team
    end
  end
end
