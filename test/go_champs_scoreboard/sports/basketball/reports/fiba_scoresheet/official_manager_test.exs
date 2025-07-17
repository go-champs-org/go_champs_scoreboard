defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.OfficialManagerTest do
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.OfficialManager

  use ExUnit.Case

  describe "bootstrap/2" do
    test "returns an empty official when no official is provided in the game state" do
      game_state = %{
        officials: []
      }

      result = OfficialManager.bootstrap(game_state, :scorer)

      assert result == %FibaScoresheet.Official{
               id: "",
               name: ""
             }
    end

    test "returns the official with the correct type" do
      game_state = %{
        officials: [
          %OfficialState{id: "1", name: "John Doe", type: :scorer}
        ]
      }

      result = OfficialManager.bootstrap(game_state, :scorer)

      assert result.id == "1"
      assert result.name == "John Doe"
    end
  end
end
