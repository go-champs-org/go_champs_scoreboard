defmodule GoChampsScoreboard.Sports.Basketball.PlayerClockTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Models.GameClockState

  describe "player_tick/2" do
    test "increments minutes_played when game clock is running and clock has time left and player is playing" do
      player = %{
        state: :playing,
        stats_values: %{"minutes_played" => 0},
        time: 3
      }

      game_clock_state = %GameClockState{state: :running}

      updated_player =
        GoChampsScoreboard.Sports.Basketball.PlayerClock.player_tick(player, game_clock_state)

      assert updated_player.stats_values["minutes_played"] == 1
    end

    test "does not increment minutes_played when game clock is running but has no time left" do
      player = %{
        state: :playing,
        stats_values: %{"minutes_played" => 0}
      }

      game_clock_state = %GameClockState{state: :running, time: 0}

      updated_player =
        GoChampsScoreboard.Sports.Basketball.PlayerClock.player_tick(player, game_clock_state)

      assert updated_player.stats_values["minutes_played"] == 0
    end

    test "does not increment minutes_played when game clock is not running" do
      player = %{
        state: :playing,
        stats_values: %{"minutes_played" => 0}
      }

      game_clock_state = %GameClockState{state: :stopped}

      updated_player =
        GoChampsScoreboard.Sports.Basketball.PlayerClock.player_tick(player, game_clock_state)

      assert updated_player.stats_values["minutes_played"] == 0
    end

    test "does not increment minutes_played when player is not playing" do
      player = %{
        state: :on_bench,
        stats_values: %{"minutes_played" => 0}
      }

      game_clock_state = %GameClockState{state: :running}

      updated_player =
        GoChampsScoreboard.Sports.Basketball.PlayerClock.player_tick(player, game_clock_state)

      assert updated_player.stats_values["minutes_played"] == 0
    end
  end
end
