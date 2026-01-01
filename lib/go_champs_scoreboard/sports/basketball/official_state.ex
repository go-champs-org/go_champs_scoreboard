defmodule GoChampsScoreboard.Sports.Basketball.OfficialState do
  @moduledoc """
  Module for Basketball OfficialState related functions.
  """

  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Games.Officials

  @spec bootstrap_officials() :: [OfficialState.t()]
  def bootstrap_officials() do
    [
      Officials.bootstrap("", "crew_chief", "", ""),
      Officials.bootstrap("", "umpire_1", "", ""),
      Officials.bootstrap("", "umpire_2", "", ""),
      Officials.bootstrap("", "scorer", "", ""),
      Officials.bootstrap("", "assistant_scorer", "", ""),
      Officials.bootstrap("", "timekeeper", "", ""),
      Officials.bootstrap("", "shot_clock_operator", "", "")
    ]
  end
end
