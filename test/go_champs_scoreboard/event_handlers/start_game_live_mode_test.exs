defmodule GoChampsScoreboard.EventHandlers.StartGameLiveModeTest do
  use ExUnit.Case
  import Mox

  alias GoChampsScoreboard.EventHandlers.StartGameLiveMode
  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState}
  alias GoChampsScoreboard.GameTickerSupervisorMock

  describe "handle/2" do
    test "starts GameTicker and updates live_mode to :running in GameState" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        live_state: %LiveState{state: :not_started}
      }

      expect(GameTickerSupervisorMock, :start_game_ticker, fn _game_id -> :ok end)

      game = StartGameLiveMode.handle(game_state, %{}, GameTickerSupervisorMock)

      assert game.live_state.state == :running
      verify!()
    end
  end
end
