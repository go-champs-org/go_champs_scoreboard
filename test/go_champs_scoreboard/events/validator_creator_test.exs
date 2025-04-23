defmodule GoChampsScoreboard.Events.ValidatorCreatorTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.ValidatorCreator
  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState, GameClockState}

  describe "validate_and_create/2 for AddPlayerToTeam" do
    @event_key "add-player-to-team"
    @game_id "some-game-id"

    test "returns :ok and event" do
      current_game_state = set_test_game()

      assert {:ok, event} =
               ValidatorCreator.validate_and_create(@event_key, @game_id, %{
                 "team_type" => "home",
                 "name" => "Michael Jordan",
                 "number" => 23
               })

      assert event.key == @event_key
      assert event.game_id == @game_id
      assert event.clock_state_time_at == current_game_state.clock_state.time
      assert event.clock_state_period_at == current_game_state.clock_state.period

      unset_test_game()
    end
  end

  describe "validate_and_create/2 for UnknownEvent" do
    @event_key "unknown-event"
    @game_id "some-game-id"

    test "returns error message" do
      assert {:error, "Event definition not registered for key: unknown-event"} =
               ValidatorCreator.validate_and_create(@event_key, @game_id)
    end
  end

  defp set_test_game() do
    away_team = TeamState.new("Some away team")
    home_team = TeamState.new("Some home team")
    clock_state = GameClockState.new()
    live_state = LiveState.new()
    game_state = GameState.new("some-game-id", away_team, home_team, clock_state, live_state)
    Redix.command(:games_cache, ["SET", "some-game-id", game_state])
    game_state
  end

  defp unset_test_game() do
    Redix.command(:games_cache, ["DEL", "some-game-id"])
  end
end
