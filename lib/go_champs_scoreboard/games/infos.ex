defmodule GoChampsScoreboard.Games.Infos do
  alias GoChampsScoreboard.Games.Models.InfoState

  @spec add_game_asset(InfoState.t(), String.t(), String.t()) :: InfoState.t()
  def add_game_asset(info_state, asset_type, asset_url) do
    %{
      info_state
      | assets: [
          %{type: asset_type, url: asset_url} | info_state.assets
        ]
    }
  end
end
