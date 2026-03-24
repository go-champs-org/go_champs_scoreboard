defmodule GoChampsScoreboard.Games.GameProcessTest do
  use ExUnit.Case, async: false

  alias GoChampsScoreboard.Events.Definitions.UpdateClockStateDefinition
  alias GoChampsScoreboard.Games.GameProcess
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.LiveState
  alias GoChampsScoreboard.Games.Models.TeamState

  setup do
    game_state = set_test_game()
    {:ok, pid} = GameProcess.start_link(game_state.id)

    on_exit(fn ->
      if Process.alive?(pid), do: GenServer.stop(pid)
      unset_test_game(game_state.id)
    end)

    {:ok, game_state: game_state}
  end

  describe "react_to_event/2" do
    test "applies the event and returns updated game state", %{game_state: game_state} do
      event = UpdateClockStateDefinition.create(game_state.id, 10, 1, %{"state" => "running"})

      result = GameProcess.react_to_event(game_state.id, event)

      assert result.clock_state.state == :running
    end

    test "persists updated state so subsequent calls see the new state", %{game_state: game_state} do
      event1 = UpdateClockStateDefinition.create(game_state.id, 10, 1, %{"state" => "running"})
      event2 = UpdateClockStateDefinition.create(game_state.id, 9, 1, %{"state" => "paused"})

      GameProcess.react_to_event(game_state.id, event1)
      result = GameProcess.react_to_event(game_state.id, event2)

      assert result.clock_state.state == :paused
    end

    test "serializes concurrent events without losing updates", %{game_state: game_state} do
      n = 20

      tasks =
        Enum.map(1..n, fn i ->
          Task.async(fn ->
            event =
              UpdateClockStateDefinition.create(game_state.id, i, 1, %{"state" => "running"})

            GameProcess.react_to_event(game_state.id, event)
          end)
        end)

      results = Enum.map(tasks, &Task.await/1)

      assert length(results) == n
      assert Enum.all?(results, fn r -> r.clock_state.state == :running end)
    end
  end

  describe "get_state/1" do
    test "returns current game state held by the process", %{game_state: game_state} do
      result = GameProcess.get_state(game_state.id)

      assert result.id == game_state.id
    end

    test "reflects state changes after react_to_event", %{game_state: game_state} do
      event = UpdateClockStateDefinition.create(game_state.id, 10, 1, %{"state" => "running"})
      GameProcess.react_to_event(game_state.id, event)

      result = GameProcess.get_state(game_state.id)

      assert result.clock_state.state == :running
    end
  end

  defp set_test_game do
    away_team = TeamState.new(Ecto.UUID.generate(), "Some away team")
    home_team = TeamState.new(Ecto.UUID.generate(), "Some home team")
    clock_state = GameClockState.new()
    live_state = LiveState.new(:not_started)

    game_state =
      GameState.new(Ecto.UUID.generate(), away_team, home_team, clock_state, live_state)

    Redix.command(:games_cache, ["SET", "game_state:#{game_state.id}", game_state])

    game_state
  end

  defp unset_test_game(game_id) do
    Redix.command(:games_cache, ["DEL", "game_state:#{game_id}"])
  end
end
