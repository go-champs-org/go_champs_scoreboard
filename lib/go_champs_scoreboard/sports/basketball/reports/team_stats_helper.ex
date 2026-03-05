defmodule GoChampsScoreboard.Sports.Basketball.Reports.TeamStatsHelper do
  @moduledoc """
  Common utilities for working with team statistics across different report types.
  """

  alias GoChampsScoreboard.Games.Models.TeamState

  @doc """
  Maps period statistics to a points_by_period map.
  Takes a TeamState and extracts points scored by period.
  """
  @spec map_points_by_period(TeamState.t()) :: %{integer() => integer()}
  def map_points_by_period(team_state) do
    period_stats = Map.get(team_state, :period_stats) || %{}

    period_stats
    |> Enum.map(fn {period, stats} ->
      points = Map.get(stats, "points", 0)
      {period, if(is_nil(points), do: 0, else: points)}
    end)
    |> Enum.into(%{})
  end
end
