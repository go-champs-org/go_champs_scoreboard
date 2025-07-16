defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.CoachManager do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  @spec find_coach(FibaScoresheet.Team.t(), atom()) :: FibaScoresheet.Coach.t() | nil
  def find_coach(team, coach_id) do
    [team.coach, team.assistant_coach]
    |> Enum.find(fn coach -> coach.id == coach_id end)
  end
end
