defmodule GoChampsScoreboard.Games.TemporalStats do
  alias GoChampsScoreboard.Games.Models.TemporalStatsState

  @two_days_in_seconds 172_800

  def handle(game_state) do
    new_state = update_temporal(game_state)

    update(game_state.id, new_state)
  end

  def calculate_seconds_played(current_player_temporal_stats) do
    current_player_temporal_stats.stats_values.seconds_played + 1
  end

  def calculate_player_temporal_stats(current_player_temporal_stats) do
    player_temporal_stats =
      case current_player_temporal_stats do
        nil ->
          %TemporalStatsState{
            stats_values: %{
              seconds_played: 0
            }
          }

        value ->
          value
      end

    updated_stats_values =
      player_temporal_stats.stats_values
      |> Map.put(:seconds_played, calculate_seconds_played(player_temporal_stats))

    player_temporal_stats
    |> Map.put(:stats_values, updated_stats_values)
  end

  defp update_temporal(game_state) do
    current_temporal_stats =
      case get(game_state.id) do
        {:ok, nil} -> %{}
        {:ok, temporal_stats} -> temporal_stats
      end

    if game_state.clock_state.state == :running do
      playing_players =
        (game_state.home_team.players
         |> Enum.filter(fn player -> player.state == :playing end)) ++
          (game_state.away_team.players
           |> Enum.filter(fn player -> player.state == :playing end))

      Enum.reduce(playing_players, current_temporal_stats, fn player, acc ->
        player_stats = calculate_player_temporal_stats(current_temporal_stats[player.id])
        Map.merge(acc, %{player.id => player_stats})
      end)
    else
      current_temporal_stats
    end
  end

  def get(game_id) do
    Redix.command(:games_cache, ["GET", temporal_stats_key(game_id)])
  end

  def update(game_id, stats) do
    Redix.command(:games_cache, [
      "SET",
      temporal_stats_key(game_id),
      Poison.encode!(stats),
      "EX",
      @two_days_in_seconds
    ])
  end

  defp temporal_stats_key(game_id) do
    "temporal_stats:#{game_id}"
  end
end
