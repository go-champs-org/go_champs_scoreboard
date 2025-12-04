defmodule GoChampsScoreboard.Games.Coaches do
  alias GoChampsScoreboard.Statistics.Models.Stat
  alias GoChampsScoreboard.Statistics.Operations
  alias GoChampsScoreboard.Games.Models.CoachState

  @spec bootstrap(String.t(), CoachState.type()) :: CoachState.t()
  def bootstrap(name, type) do
    Ecto.UUID.generate()
    |> CoachState.new(name, type)
  end

  @spec update_manual_stats_values(CoachState.t(), Stat.t(), String.t()) :: CoachState.t()
  def update_manual_stats_values(coach_state, player_stat, operation) do
    new_stat_value =
      Map.fetch!(coach_state.stats_values, player_stat.key)
      |> Operations.calc(operation)

    if new_stat_value < 0 do
      coach_state
    else
      coach_state
      |> update_stats_values(player_stat, new_stat_value)
    end
  end

  @spec update_calculated_stats_values(CoachState.t(), [Stat.t()]) :: CoachState.t()
  def update_calculated_stats_values(coach_state, player_stats) do
    player_stats
    |> Enum.reduce(coach_state, fn
      player_stat, current_coach_state ->
        update_calculated_stat_value(current_coach_state, player_stat)
    end)
  end

  @spec update_state(CoachState.t(), CoachState.state()) :: CoachState.t()
  def update_state(coach_state, coach_state_update) do
    Map.put(coach_state, :state, coach_state_update)
  end

  @spec update_calculated_stat_value(CoachState.t(), Stat.t()) :: CoachState.t()
  defp update_calculated_stat_value(coach_state, player_stat) do
    new_stat_value =
      coach_state
      |> player_stat.calculation_function.()

    coach_state
    |> update_stats_values(player_stat, new_stat_value)
  end

  @spec update_stats_values(CoachState.t(), Stat.t(), number()) :: CoachState.t()
  defp update_stats_values(coach_state, player_stat, new_value) do
    %{
      coach_state
      | stats_values: Map.replace(coach_state.stats_values, player_stat.key, new_value)
    }
  end
end
