defmodule GoChampsScoreboard.EventHandlers.GameTickTest do
  use ExUnit.Case

  alias GoChampsScoreboard.EventHandlers.GameTick
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState

  describe "handle/1" do
    test "returns the game state with updated game clock for basketball" do
      game_state = %GameState{
        id: "1",
        sport_id: "basketball",
        clock_state: %GameClockState{
          time: 10,
          period: 1,
          state: :running
        }
      }

      game = GameTick.handle(game_state)

      assert game.game_clock.time == 9
      assert game.game_clock.period == 1
      assert game.game_clock.state == :running
    end
  end
end
