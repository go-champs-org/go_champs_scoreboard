defmodule GoChampsScoreboard.Games.OfficialsTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Officials

  describe "bootstrap" do
    test "returns a new official state with new random id, given name and type" do
      official_state = Officials.bootstrap("Referee", "crew_chief")

      assert is_bitstring(official_state.id)
      assert "Referee" == official_state.name
      assert :crew_chief == official_state.type
    end
  end
end
