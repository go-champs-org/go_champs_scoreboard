defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EndPeriodProcessor do
  @moduledoc """
  Processes the end of a period in the FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(_event_log, data) do
    updated_home_team =
      data
      |> FibaScoresheetManager.find_team("home")
      |> TeamManager.mark_score_as_last_of_period()

    updated_away_team =
      data
      |> FibaScoresheetManager.find_team("away")
      |> TeamManager.mark_score_as_last_of_period()

    data
    |> FibaScoresheetManager.update_team("home", updated_home_team)
    |> FibaScoresheetManager.update_team("away", updated_away_team)
  end
end
