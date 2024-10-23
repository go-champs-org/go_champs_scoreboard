defmodule GoChampsScoreboard.EventHandlers.EndGameLiveModeTest do
  use ExUnit.Case
  import Mox

  alias GoChampsScoreboard.EventHandlers.EndGameLiveMode
  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState}
  alias GoChampsScoreboard.GameTickerSupervisorMock

  setup :verify_on_exit!

  describe "handle/2" do
    test "terminate GameTicker and updates live_state to :ended in GameState" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        live_state: %LiveState{state: :running}
      }

      expect(GameTickerSupervisorMock, :stop_game_ticker, fn _game_id -> :ok end)

      game = EndGameLiveMode.handle(game_state, %{}, GameTickerSupervisorMock)

      assert game.live_state.state == :ended
      verify!()
    end
  end
end
