defmodule GoChampsScoreboard.Sports.Basketball.PlayerClock do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.GameClockState

  @spec player_tick(PlayerState.t(), GameClockState.t()) :: PlayerState.t()
  def player_tick(player, game_clock_state) do
    case {game_clock_state.state, player.state} do
      {:running, :playing} ->
        case game_clock_state.time do
          time when time > 0 ->
            increment_minutes_played(player)

          _ ->
            player
        end

      _ ->
        player
    end
  end

  defp increment_minutes_played(player) do
    updated_stats =
      player.stats_values
      |> Map.update!("minutes_played", fn minutes_played ->
        minutes_played + 1
      end)

    Map.put(player, :stats_values, updated_stats)
  end
end
