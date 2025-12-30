defmodule GoChampsScoreboard.Sports.Basketball.OfficialStateTest do
  use ExUnit.Case, async: true

  alias GoChampsScoreboard.Sports.Basketball.OfficialState

  describe "bootstrap_officials/0" do
    test "returns a list of official states with correct roles" do
      officials = OfficialState.bootstrap_officials()

      assert length(officials) == 7

      types = Enum.map(officials, fn official -> official.type end)

      assert :crew_chief in types
      assert :umpire_1 in types
      assert :umpire_2 in types
      assert :scorer in types
      assert :assistant_scorer in types
      assert :timekeeper in types
      assert :shot_clock_operator in types
    end
  end
end
