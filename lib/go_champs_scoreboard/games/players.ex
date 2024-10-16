defmodule GoChampsScoreboard.Games.Players do
  alias GoChampsScoreboard.Statistics.Models.Stat
  alias GoChampsScoreboard.Statistics.Operations
  alias GoChampsScoreboard.Games.Models.PlayerState

  @spec bootstrap(String.t(), number()) :: PlayerState.t()
  def bootstrap(name, number) do
    Ecto.UUID.generate()
    |> PlayerState.new(name, number)
  end

  @spec update_manual_stats_values(PlayerState.t(), Stat.t(), String.t()) :: PlayerState.t()
  def update_manual_stats_values(player_state, player_stat, operation) do
    new_stat_value =
      Map.fetch!(player_state.stats_values, player_stat.key)
      |> Operations.calc(operation)

    player_state
    |> update_stats_values(player_stat, new_stat_value)
  end

  @spec update_calculated_stats_values(PlayerState.t(), [Stat.t()]) :: PlayerState.t()
  def update_calculated_stats_values(player_state, player_stats) do
    player_stats
    |> Enum.reduce(player_state, fn
      player_stat, current_player_state ->
        update_calculated_stat_value(current_player_state, player_stat)
    end)
  end

  @spec update_calculated_stat_value(PlayerState.t(), Stat.t()) :: PlayerState.t()
  defp update_calculated_stat_value(player_state, player_stat) do
    new_stat_value =
      player_state
      |> player_stat.calculation_function.()

    player_state
    |> update_stats_values(player_stat, new_stat_value)
  end

  @spec update_stats_values(PlayerState.t(), Stat.t(), number()) :: PlayerState.t()
  defp update_stats_values(player_state, player_stat, new_value) do
    %{
      player_state
      | stats_values: Map.replace(player_state.stats_values, player_stat.key, new_value)
    }
  end
end
