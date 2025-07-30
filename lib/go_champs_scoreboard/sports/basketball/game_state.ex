defmodule GoChampsScoreboard.Sports.Basketball.GameState do
  alias GoChampsScoreboard.Events.GameSnapshot
  alias GoChampsScoreboard.Games.Models.GameState

  @spec map_from_snapshot(GameState.t(), GameSnapshot.t()) :: GameState.t()
  def map_from_snapshot(game_state, snapshot) do
    case snapshot.state do
      %GameState{} = restored_state ->
        restored_state

      _ ->
        game_state
    end
  end
end
