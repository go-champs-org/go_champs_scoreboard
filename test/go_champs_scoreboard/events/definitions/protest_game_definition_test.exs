defmodule GoChampsScoreboard.Events.Definitions.ProtestGameDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.ProtestGameDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.StreamConfig

  describe "key/0" do
    test "returns the correct key" do
      assert ProtestGameDefinition.key() == "protest-game"
    end
  end

  describe "validate/2" do
    test "always returns ok" do
      game_state = %GameState{}
      payload = %{"team-id" => "team-123", "player-id" => "player-456"}

      assert ProtestGameDefinition.validate(game_state, payload) == {:ok}
    end
  end

  describe "create/4" do
    test "creates an event with the correct attributes" do
      game_id = "game-123"
      clock_state_time_at = 600
      clock_state_period_at = 1
      payload = %{"team-id" => "team-123", "player-id" => "player-456"}

      event =
        ProtestGameDefinition.create(game_id, clock_state_time_at, clock_state_period_at, payload)

      assert %Event{} = event
      assert event.key == "protest-game"
      assert event.game_id == game_id
      assert event.clock_state_time_at == clock_state_time_at
      assert event.clock_state_period_at == clock_state_period_at
      assert event.payload == payload
    end
  end

  describe "handle/2" do
    test "returns the game state unchanged" do
      game_state = %GameState{id: "game-123"}

      event = %Event{
        key: "protest-game",
        payload: %{"team-id" => "team-123", "player-id" => "player-456"}
      }

      result = ProtestGameDefinition.handle(game_state, event)

      assert result == game_state
    end

    test "works with default event parameter" do
      game_state = %GameState{id: "game-123"}

      result = ProtestGameDefinition.handle(game_state)

      assert result == game_state
    end
  end

  describe "stream_config/0" do
    test "returns a StreamConfig struct" do
      config = ProtestGameDefinition.stream_config()

      assert %StreamConfig{} = config
    end
  end
end
