defmodule GoChampsScoreboard.Games.Models.ViewSettingsStateTest do
  use ExUnit.Case

  import GoChampsScoreboard.GameStateFixtures

  alias GoChampsScoreboard.Games.Bootstrapper
  alias GoChampsScoreboard.Games.Models.{GameState, ViewSettingsState}

  describe "new/3" do
    test "defaults rules_version to fiba-2024" do
      assert ViewSettingsState.new().rules_version == "fiba-2024"
    end

    test "sets the given rules_version" do
      state = ViewSettingsState.new("basketball-medium-stats", [], "fiba-2026")

      assert state.rules_version == "fiba-2026"
    end
  end

  describe "Bootstrapper.map_view_settings_state/1" do
    test "defaults rules_version to fiba-2024 when there is no scoreboard setting" do
      assert Bootstrapper.map_view_settings_state(nil).rules_version == "fiba-2024"
    end

    test "defaults rules_version to fiba-2024 when rules_version is nil" do
      state = Bootstrapper.map_view_settings_state(%{"rules_version" => nil})

      assert state.rules_version == "fiba-2024"
    end

    test "maps rules_version from the scoreboard setting" do
      state = Bootstrapper.map_view_settings_state(%{"rules_version" => "fiba-2026"})

      assert state.rules_version == "fiba-2026"
    end
  end

  describe "GameState.from_json/1" do
    test "defaults rules_version to fiba-2024 for game states stored without it" do
      json =
        game_state_fixture()
        |> Poison.encode!()
        |> Poison.decode!()
        |> put_in(["view_settings_state"], %{
          "view" => "basketball-medium-stats",
          "available_views" => []
        })
        |> Poison.encode!()

      assert GameState.from_json(json).view_settings_state.rules_version == "fiba-2024"
    end

    test "keeps rules_version after a round trip" do
      json =
        game_state_fixture()
        |> Map.put(
          :view_settings_state,
          ViewSettingsState.new("basketball-medium-stats", [], "fiba-2026")
        )
        |> Poison.encode!()

      assert GameState.from_json(json).view_settings_state.rules_version == "fiba-2026"
    end
  end
end
