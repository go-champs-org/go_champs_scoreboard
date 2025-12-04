defmodule GoChampsScoreboard.Sports.Basketball.CoachState do
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Coaches

  @spec update_coach_state(CoachState.t()) :: CoachState.t()
  def update_coach_state(coach) do
    fouls = Map.get(coach.stats_values, "fouls", 0)
    game_disqualifying_fouls = Map.get(coach.stats_values, "fouls_game_disqualifying", 0)
    current_state = Map.get(coach, :state, :available)

    if (fouls >= 3 or game_disqualifying_fouls >= 1) and current_state != :disqualified do
      Coaches.update_state(coach, :disqualified)
    else
      coach
    end
  end
end
