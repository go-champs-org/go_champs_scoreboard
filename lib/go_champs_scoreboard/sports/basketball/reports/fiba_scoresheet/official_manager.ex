defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.OfficialManager do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.Models.GameState

  @spec bootstrap(GameState.t(), atom()) :: FibaScoresheet.Official.t()
  def bootstrap(game_state, official_type) do
    Enum.find(game_state.officials, %FibaScoresheet.Official{id: "", name: ""}, fn official ->
      official.type == official_type
    end)
  end
end
