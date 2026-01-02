defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.OfficialManager do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.Models.GameState

  @spec bootstrap(GameState.t(), atom()) :: FibaScoresheet.Official.t()
  def bootstrap(game_state, official_type) do
    case Enum.find(game_state.officials, fn official ->
           official.type == official_type
         end) do
      nil ->
        %FibaScoresheet.Official{id: "", name: "", signature: nil}

      official ->
        %FibaScoresheet.Official{
          id: official.id,
          name: official.name,
          signature: Map.get(official, :signature, nil)
        }
    end
  end
end
