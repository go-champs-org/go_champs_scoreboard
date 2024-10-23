defmodule GoChampsScoreboard.EventHandlers.EndGameLiveMode do
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.GameTickerSupervisor

  @spec handle(GameState.t(), any()) :: GameState.t()
  def handle(game_state, _, game_ticker_supervisor \\ GameTickerSupervisor) do
    game_ticker_supervisor.stop_game_ticker(game_state.id)

    %{game_state | live_state: %{state: :ended}}
  end
end
