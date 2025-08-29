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
    test "updates game state protest with payload data" do
      game_state = %GameState{
        id: "game-123",
        sport_id: "basketball",
        protest: GoChampsScoreboard.Games.Models.ProtestState.new(:none, "", :no_protest)
      }

      event = %Event{
        key: "protest-game",
        payload: %{"team-type" => "home", "player-id" => "player-456"}
      }

      result = ProtestGameDefinition.handle(game_state, event)

      assert result.protest.team_type == :home
      assert result.protest.player_id == "player-456"
      assert result.protest.state == :protest_filed
    end

    test "returns game state unchanged when event is nil" do
      game_state = %GameState{id: "game-123"}

      result = ProtestGameDefinition.handle(game_state)

      assert result == game_state
    end

    test "returns game state unchanged when event payload is nil" do
      game_state = %GameState{id: "game-123"}

      event = %Event{
        key: "protest-game",
        payload: nil
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
