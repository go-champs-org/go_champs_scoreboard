defmodule GoChampsScoreboard.Games.OfficialsTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Officials

  describe "bootstrap" do
    test "returns a new official state with new random id, given name and type" do
      official_state = Officials.bootstrap("Referee", "crew_chief")

      assert nil != official_state.id
      assert "Referee" == official_state.name
      assert :crew_chief == official_state.type
    end

    test "returns a new official state with license_number when provided" do
      official_state = Officials.bootstrap("John Doe", "scorer", "SC001")

      assert nil != official_state.id
      assert "John Doe" == official_state.name
      assert :scorer == official_state.type
      assert "SC001" == official_state.license_number
      assert nil == official_state.federation
    end

    test "returns a new official state with all arguments when provided" do
      official_state = Officials.bootstrap("Jane Smith", "timekeeper", "TK001", "FIBA")

      assert nil != official_state.id
      assert "Jane Smith" == official_state.name
      assert :timekeeper == official_state.type
      assert "TK001" == official_state.license_number
      assert "FIBA" == official_state.federation
    end

    test "handles nil license_number and federation gracefully" do
      official_state = Officials.bootstrap("Mike Johnson", "umpire_1", nil, nil)

      assert nil != official_state.id
      assert "Mike Johnson" == official_state.name
      assert :umpire_1 == official_state.type
      assert nil == official_state.license_number
      assert nil == official_state.federation
    end

    test "creates different officials with unique ids" do
      official1 = Officials.bootstrap("Official 1", "scorer")
      official2 = Officials.bootstrap("Official 2", "scorer")

      assert official1.id != official2.id
    end

    test "handles all valid official types" do
      valid_types = [
        "scorer",
        "assistant_scorer",
        "timekeeper",
        "shot_clock_operator",
        "crew_chief",
        "umpire_1",
        "umpire_2"
      ]

      Enum.each(valid_types, fn type ->
        official = Officials.bootstrap("Test Official", type, "LIC001", "TEST")

        assert is_bitstring(official.id)
        assert "Test Official" == official.name
        assert String.to_existing_atom(type) == official.type
        assert "LIC001" == official.license_number
        assert "TEST" == official.federation
      end)
    end

    test "creates official with only name and type, other fields default to nil" do
      official_state = Officials.bootstrap("Basic Official", "assistant_scorer")

      assert nil != official_state.id
      assert "Basic Official" == official_state.name
      assert :assistant_scorer == official_state.type
      assert nil == official_state.license_number
      assert nil == official_state.federation
    end

    test "creates official with empty string license_number and federation" do
      official_state = Officials.bootstrap("Test Official", "shot_clock_operator", "", "")

      assert nil != official_state.id
      assert "Test Official" == official_state.name
      assert :shot_clock_operator == official_state.type
      assert "" == official_state.license_number
      assert "" == official_state.federation
    end

    test "raises ArgumentError for invalid official type" do
      assert_raise ArgumentError, "Invalid official type: invalid_type", fn ->
        Officials.bootstrap("Invalid Official", "invalid_type")
      end
    end
  end
end
