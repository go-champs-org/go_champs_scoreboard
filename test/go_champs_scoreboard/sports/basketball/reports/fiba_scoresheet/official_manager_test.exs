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
               name: "",
               signature: nil,
               federation: nil
             }
    end

    test "returns the official with the correct type" do
      game_state = %{
        officials: [
          %OfficialState{
            id: "1",
            name: "John Doe",
            signature: "some-official-signature",
            type: :scorer,
            federation: "FIBA"
          }
        ]
      }

      %FibaScoresheet.Official{id: id, name: name, signature: signature, federation: federation} =
        OfficialManager.bootstrap(game_state, :scorer)

      assert id == "1"
      assert name == "John Doe"
      assert signature == "some-official-signature"
      assert federation == "FIBA"
    end
  end
end
