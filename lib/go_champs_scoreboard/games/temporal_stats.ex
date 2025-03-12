defmodule GoChampsScoreboard.Games.TemporalStats do
  alias GoChampsScoreboard.Games.Models.TemporalStatsState

  @two_days_in_seconds 172_800

  def handle(game_state) do
    new_state = update_temporal(game_state)

    update(game_state.id, new_state)
  end

  def calculate_player_temporal_stats(current_player_temporal_stats) :: TemporalStatsState.t() do
    current_player_temporal_stats.seconds_played =
      calculate_player_temporal_stats(current_player_temporal_stats)

    current_player_temporal_stats
  end

  def calculate_seconds_played(current_player_temporal_stats :: TemporalStatsState.t()) do
    current_player_temporal_stats.seconds_played + 1
  end

  defp update_temporal(game_state) do
    if game_state.clock_state.state == :running do
      playing_player =
        game_state.home_team.players
        |> (Enum.filter(fn player -> player.state == :playing end) ++
              game_state.away_team.players)
        |> Enum.filter(fn player -> player.state == :playing end)

      current_temporal_stats = get(game_state.id)

      Enum.reduce(playing_player, current_temporal_stats, fn player, acc ->
        player_stats = calculate_player_temporal_stats(current_temporal_stats[player.id])
        Map.merge(acc, %{player.id => player_stats})
      end)
    else
      game_state.temporal_stats
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
