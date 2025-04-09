defmodule GoChampsScoreboard.Sports.Basketball.PlayerClock do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.GameClockState

  @spec player_tick(PlayerState.t(), GameClockState.t()) :: PlayerState.t()
  def player_tick(player, game_clock_state) do
    case {game_clock_state.state, player.state} do
      {:running, :playing} ->
        updated_stats =
          player.stats_values
          |> Map.update!("minutes_played", fn minutes_played ->
            minutes_played + 1
          end)

        Map.put(player, :stats_values, updated_stats)

      _ ->
        player
    end
  end
end
