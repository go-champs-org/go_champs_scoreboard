defmodule GoChampsScoreboard.Sports.Basketball.GameState do
  alias GoChampsScoreboard.Sports.Basketball.TeamState
  alias GoChampsScoreboard.Sports.Basketball.GameClock
  alias GoChampsScoreboard.Events.GameSnapshot
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Sports.Basketball.Basketball
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Games.Games

  @spec copy_all_stats_from_game_state(GameState.t(), GameState.t()) :: GameState.t()
  def copy_all_stats_from_game_state(source_game_state, target_game_state) do
    ["home", "away"]
    |> Enum.reduce(target_game_state, fn team_type, acc_game_state ->
      updated_team =
        copy_team_stats_from_source(
          acc_game_state,
          source_game_state,
          team_type
        )

      Games.update_team(acc_game_state, team_type, updated_team)
    end)
  end

  @spec map_from_snapshot(GameState.t(), GameSnapshot.t()) :: GameState.t()
  def map_from_snapshot(game_state, snapshot) do
    case snapshot.state do
      %GameState{} = restored_state ->
        valid_keys = get_valid_stat_keys()

        updated_game =
          ["home", "away"]
          |> Enum.reduce(game_state, fn team_type, acc_game_state ->
            updated_team =
              update_team_from_snapshot(
                acc_game_state,
                restored_state,
                team_type,
                valid_keys
              )

            Games.update_team(acc_game_state, team_type, updated_team)
          end)

        updated_game
        |> maybe_update_info(restored_state)
        |> maybe_update_clock_state(restored_state)

      _ ->
        game_state
    end
  end

  defp maybe_update_clock_state(game_state, restored_state) do
    if restored_state.clock_state.state == :not_started do
      Games.update_clock_state(game_state, restored_state.clock_state)
    else
      game_state
    end
  end

  defp maybe_update_info(game_state, restored_state) do
    if restored_state.clock_state.state == :not_started do
      Games.update_info(game_state, restored_state.info)
    else
      game_state
    end
  end

  defp update_team_players_in_game_state(
         current_team,
         restored_state,
         team_type,
         valid_stat_keys
       ) do
    restored_team = Teams.find_team(restored_state, team_type)

    current_players = current_team.players || []
    restored_players = restored_team.players || []

    updated_team =
      current_players
      |> Enum.reduce(current_team, fn current_player, acc_team ->
        case Enum.find(restored_players, &(&1.id == current_player.id)) do
          nil ->
            acc_team

          restored_player ->
            updated_player =
              update_player_from_snapshot(current_player, restored_player, valid_stat_keys)

            Teams.update_player_in_team(acc_team, updated_player)
        end
      end)

    updated_team
  end

  defp update_team_coaches_in_game_state(
         current_team,
         restored_state,
         team_type,
         valid_stat_keys
       ) do
    restored_team = Teams.find_team(restored_state, team_type)

    current_coaches = current_team.coaches || []
    restored_coaches = restored_team.coaches || []

    updated_team =
      current_coaches
      |> Enum.reduce(current_team, fn current_coach, acc_team ->
        case Enum.find(restored_coaches, &(&1.id == current_coach.id)) do
          nil ->
            acc_team

          restored_coach ->
            updated_coach =
              update_coach_from_snapshot(current_coach, restored_coach, valid_stat_keys)

            Teams.update_coach_in_team(acc_team, updated_coach)
        end
      end)

    updated_team
  end

  defp update_player_from_snapshot(current_player, restored_player, valid_stat_keys) do
    filtered_stats_values =
      restored_player.stats_values
      |> Enum.filter(fn {key, _value} -> MapSet.member?(valid_stat_keys, key) end)
      |> Enum.into(%{})

    updated_stats_values = Map.merge(current_player.stats_values, filtered_stats_values)

    %{
      current_player
      | state: restored_player.state,
        stats_values: updated_stats_values
    }
  end

  defp update_coach_from_snapshot(current_coach, restored_coach, valid_stat_keys) do
    filtered_stats_values =
      restored_coach.stats_values
      |> Enum.filter(fn {key, _value} -> MapSet.member?(valid_stat_keys, key) end)
      |> Enum.into(%{})

    updated_stats_values = Map.merge(current_coach.stats_values, filtered_stats_values)

    # Get the restored coach's state, handling both struct and map cases
    restored_state =
      cond do
        is_struct(restored_coach) -> restored_coach.state || :available
        is_map(restored_coach) -> Map.get(restored_coach, :state, :available)
        true -> :available
      end

    # Get current coach state safely
    current_state =
      cond do
        is_struct(current_coach) -> current_coach.state || :available
        is_map(current_coach) -> Map.get(current_coach, :state, :available)
        true -> :available
      end

    # Use restored state if available, otherwise keep current state
    final_state = restored_state || current_state

    Map.put(current_coach, :state, final_state)
    |> Map.put(:stats_values, updated_stats_values)
  end

  defp update_team_total_player_stats(team, restored_state, team_type, valid_stat_keys) do
    restored_team = Teams.find_team(restored_state, team_type)

    restored_total_stats = restored_team.total_player_stats || %{}

    filtered_restored_stats =
      restored_total_stats
      |> Enum.filter(fn {key, _value} -> MapSet.member?(valid_stat_keys, key) end)
      |> Enum.into(%{})

    updated_total_stats = Map.merge(team.total_player_stats, filtered_restored_stats)

    %{team | total_player_stats: updated_total_stats}
  end

  defp update_team_total_coach_stats(team, restored_state, team_type, valid_stat_keys) do
    restored_team = Teams.find_team(restored_state, team_type)

    restored_total_stats = restored_team.total_coach_stats || %{}

    filtered_restored_stats =
      restored_total_stats
      |> Enum.filter(fn {key, _value} -> MapSet.member?(valid_stat_keys, key) end)
      |> Enum.into(%{})

    updated_total_stats = Map.merge(team.total_coach_stats, filtered_restored_stats)

    %{team | total_coach_stats: updated_total_stats}
  end

  defp update_team_stats(team, restored_state, team_type, valid_stat_keys) do
    restored_team = Teams.find_team(restored_state, team_type)

    # Handle case where stats_values might be nil
    restored_stats = restored_team.stats_values || %{}

    # Filter restored stats_values to only include valid stat keys
    filtered_restored_stats =
      restored_stats
      |> Enum.filter(fn {key, _value} -> MapSet.member?(valid_stat_keys, key) end)
      |> Enum.into(%{})

    # Merge: keep all current team stats, but override only the valid stat keys from restored
    updated_stats = Map.merge(team.stats_values, filtered_restored_stats)

    %{team | stats_values: updated_stats}
  end

  defp update_team_period_stats(team, restored_state, team_type) do
    restored_team = Teams.find_team(restored_state, team_type)

    # Handle case where period_stats might be nil
    restored_period_stats = restored_team.period_stats || %{}

    # Copy period_stats as-is since they represent historical data
    %{team | period_stats: restored_period_stats}
  end

  defp get_valid_stat_keys do
    %{
      player: Basketball.find_player_stat_by_type([:manual, :calculated]) |> extract_keys(),
      coach: Basketball.find_coach_stat_by_type([:manual, :calculated]) |> extract_keys(),
      team: Basketball.find_team_stat_by_type([:manual, :calculated]) |> extract_keys()
    }
  end

  defp extract_keys(stats), do: stats |> Enum.map(& &1.key) |> MapSet.new()

  defp update_team_from_snapshot(game_state, restored_state, team_type, valid_keys) do
    current_team = Teams.find_team(game_state, team_type)

    current_team
    |> update_team_players_in_game_state(restored_state, team_type, valid_keys.player)
    |> update_team_coaches_in_game_state(restored_state, team_type, valid_keys.coach)
    |> update_team_total_player_stats(restored_state, team_type, valid_keys.player)
    |> update_team_total_coach_stats(restored_state, team_type, valid_keys.coach)
    |> update_team_stats(restored_state, team_type, valid_keys.team)
    |> update_team_period_stats(restored_state, team_type)
  end

  defp copy_team_stats_from_source(target_game_state, source_game_state, team_type) do
    target_team = Teams.find_team(target_game_state, team_type)
    source_team = Teams.find_team(source_game_state, team_type)

    target_team
    |> copy_players_from_source(source_team)
    |> copy_coaches_from_source(source_team)
    |> copy_team_level_stats_from_source(source_team)
  end

  defp copy_players_from_source(target_team, source_team) do
    target_players = target_team.players || []
    source_players = source_team.players || []

    target_players
    |> Enum.reduce(target_team, fn target_player, acc_team ->
      case Enum.find(source_players, &(&1.id == target_player.id)) do
        nil ->
          acc_team

        source_player ->
          updated_player = %{
            target_player
            | name: source_player.name,
              state: source_player.state,
              stats_values: source_player.stats_values
          }

          Teams.update_player_in_team(acc_team, updated_player)
      end
    end)
  end

  defp copy_coaches_from_source(target_team, source_team) do
    target_coaches = target_team.coaches || []
    source_coaches = source_team.coaches || []

    target_coaches
    |> Enum.reduce(target_team, fn target_coach, acc_team ->
      case Enum.find(source_coaches, &(&1.id == target_coach.id)) do
        nil ->
          acc_team

        source_coach ->
          updated_coach =
            target_coach
            |> Map.put(:name, source_coach.name)
            |> Map.put(:type, Map.get(source_coach, :type, :head_coach))
            |> Map.put(:state, Map.get(source_coach, :state, :available))
            |> Map.put(:stats_values, source_coach.stats_values)

          Teams.update_coach_in_team(acc_team, updated_coach)
      end
    end)
  end

  defp copy_team_level_stats_from_source(target_team, source_team) do
    target_team
    |> Map.put(:total_player_stats, source_team.total_player_stats || %{})
    |> Map.put(:total_coach_stats, source_team.total_coach_stats || %{})
    |> Map.put(:stats_values, source_team.stats_values || %{})
    |> Map.put(:period_stats, source_team.period_stats || %{})
  end

  @spec protest_game(GameState.t(), map()) :: GameState.t()
  def protest_game(game_state, event_payload) do
    team_type = Map.get(event_payload, "team-type", "none") |> String.to_atom()
    player_id = Map.get(event_payload, "player-id", "")

    protest_state =
      GoChampsScoreboard.Games.Models.ProtestState.new(
        team_type,
        player_id,
        :protest_filed
      )

    game_state
    |> Games.update_protest_state(protest_state)
  end

  @spec register_team_wo(GameState.t(), String.t()) :: GameState.t()
  def register_team_wo(game_state, team) do
    updated_game_state =
      game_state
      |> Games.update_clock_state(GameClock.set_clock_for_wo(game_state.clock_state))
      |> Games.update_info(set_info_for_wo(game_state.info, team))

    case team do
      "home" -> set_team_stats_for_home_wo(updated_game_state)
      "away" -> set_team_stats_for_away_wo(updated_game_state)
      _ -> updated_game_state
    end
  end

  defp set_info_for_wo(info_state, "home") do
    info_state
    |> Map.put(:result_type, :home_team_walkover)
  end

  defp set_info_for_wo(info_state, "away") do
    info_state
    |> Map.put(:result_type, :away_team_walkover)
  end

  defp set_team_stats_for_home_wo(game_state) do
    updated_home_team =
      Teams.find_team(game_state, "home")
      |> TeamState.set_walkover()

    updated_away_team =
      Teams.find_team(game_state, "away")
      |> TeamState.set_walkover_against()

    game_state
    |> Games.update_team("home", updated_home_team)
    |> Games.update_team("away", updated_away_team)
  end

  defp set_team_stats_for_away_wo(game_state) do
    updated_away_team =
      Teams.find_team(game_state, "away")
      |> TeamState.set_walkover()

    updated_home_team =
      Teams.find_team(game_state, "home")
      |> TeamState.set_walkover_against()

    game_state
    |> Games.update_team("away", updated_away_team)
    |> Games.update_team("home", updated_home_team)
  end
end
