defmodule GoChampsScoreboard.Sports.Basketball.TeamState do
  @moduledoc """
  Represents the state of a basketball team in the game.
  """

  alias GoChampsScoreboard.Games.Models.TeamState, as: TeamStateModel
  alias GoChampsScoreboard.Sports.Basketball.Basketball
  alias GoChampsScoreboard.Games.Teams

  @spec set_walkover(TeamStateModel.t()) :: TeamStateModel.t()
  def set_walkover(team_state) do
    walkover_stat = Basketball.find_team_stat("game_walkover")
    calculated_team_stats = Basketball.find_calculated_team_stats()

    team_state
    |> Teams.update_manual_stats_values(walkover_stat, "check")
    |> Teams.update_calculated_stats_values(calculated_team_stats)
    |> Teams.calculate_period_stats(4)
  end

  @spec set_walkover_against(TeamStateModel.t()) :: TeamStateModel.t()
  def set_walkover_against(team_state) do
    walkover_against_stat = Basketball.find_team_stat("game_walkover_against")
    calculated_team_stats = Basketball.find_calculated_team_stats()

    team_state
    |> Teams.update_manual_stats_values(walkover_against_stat, "check")
    |> Teams.update_calculated_stats_values(calculated_team_stats)
    |> Teams.calculate_period_stats(4)
  end
end
