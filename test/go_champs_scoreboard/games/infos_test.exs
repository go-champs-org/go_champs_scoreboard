defmodule GoChampsScoreboard.Games.InfosTest do
  use ExUnit.Case, async: true
  alias GoChampsScoreboard.Games.Infos
  alias GoChampsScoreboard.Games.Models.InfoState

  describe "add_game_asset/3" do
    test "adds a new asset to the info state" do
      initial_info_state = %InfoState{
        assets: [
          %{type: "logo", url: "http://example.com/logo1.png"},
          %{type: "banner", url: "http://example.com/banner1.png"}
        ]
      }

      updated_info_state =
        Infos.add_game_asset(initial_info_state, "logo", "http://example.com/logo2.png")

      assert length(updated_info_state.assets) == 3

      assert Enum.any?(updated_info_state.assets, fn asset ->
               asset.type == "logo" and asset.url == "http://example.com/logo2.png"
             end)
    end
  end
end
