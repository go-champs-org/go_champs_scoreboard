defmodule GoChampsScoreboard.Sports.Basketball.GameState do
  alias GoChampsScoreboard.Events.GameSnapshot
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Sports.Basketball.Basketball
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Games.Games

  @spec map_from_snapshot(GameState.t(), GameSnapshot.t()) :: GameState.t()
  def map_from_snapshot(game_state, snapshot) do
    case snapshot.state do
      %GameState{} = restored_state ->
        valid_keys = get_valid_stat_keys()

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

      _ ->
        game_state
    end
  end

  defp update_team_players_in_game_state(
         current_game_state,
         restored_state,
         team_type,
         valid_stat_keys
       ) do
    current_team = Teams.find_team(current_game_state, team_type)
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

  defp get_valid_stat_keys do
    %{
      player: Basketball.find_player_stat_by_type([:manual, :calculated]) |> extract_keys(),
      team: Basketball.find_team_stat_by_type([:manual, :calculated]) |> extract_keys()
    }
  end

  defp extract_keys(stats), do: stats |> Enum.map(& &1.key) |> MapSet.new()

  defp update_team_from_snapshot(game_state, restored_state, team_type, valid_keys) do
    game_state
    |> update_team_players_in_game_state(restored_state, team_type, valid_keys.player)
    |> update_team_total_player_stats(restored_state, team_type, valid_keys.player)
    |> update_team_stats(restored_state, team_type, valid_keys.team)
  end
end
