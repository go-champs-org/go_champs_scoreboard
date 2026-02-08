defmodule GoChampsScoreboard.Events.Definitions.AddOfficialToGameDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.AddOfficialToGameDefinition

  alias GoChampsScoreboard.Games.Models.{
    GameState,
    TeamState,
    GameClockState,
    LiveState
  }

  alias GoChampsScoreboard.Events.Models.StreamConfig

  setup do
    game_state =
      GameState.new(
        "game-123",
        %TeamState{},
        %TeamState{},
        %GameClockState{},
        %LiveState{}
      )

    {:ok, game_state: game_state}
  end

  describe "key/0" do
    test "returns correct event key" do
      assert AddOfficialToGameDefinition.key() == "add-official-to-game"
    end
  end

  describe "validate/2" do
    test "validates any payload (currently returns ok for any input)" do
      assert AddOfficialToGameDefinition.validate(nil, %{}) == {:ok}

      assert AddOfficialToGameDefinition.validate(nil, %{"name" => "John", "type" => "scorer"}) ==
               {:ok}

      assert AddOfficialToGameDefinition.validate(nil, "invalid") == {:ok}
    end
  end

  describe "create/4" do
    test "creates event with correct attributes" do
      payload = %{"name" => "John Doe", "type" => "scorer"}

      event = AddOfficialToGameDefinition.create("game-123", 600, 1, payload)

      assert %Event{} = event
      assert event.key == "add-official-to-game"
      assert event.game_id == "game-123"
      assert event.clock_state_time_at == 600
      assert event.clock_state_period_at == 1
      assert event.payload == payload
    end

    test "creates event with complex payload" do
      payload = %{
        "name" => "Jane Smith",
        "type" => "crew_chief",
        "license_number" => "CC001",
        "federation" => "NBA"
      }

      event = AddOfficialToGameDefinition.create("game-456", 120, 2, payload)

      assert event.game_id == "game-456"
      assert event.clock_state_time_at == 120
      assert event.clock_state_period_at == 2
      assert event.payload == payload
    end
  end

  describe "handle/2" do
    test "adds official with minimal required fields", %{game_state: game_state} do
      payload = %{
        "name" => "John Doe",
        "type" => "scorer"
      }

      event = Event.new("add-official-to-game", "game-123", 600, 1, payload)
      updated_game = AddOfficialToGameDefinition.handle(game_state, event)
      [scorer] = updated_game.officials

      assert length(updated_game.officials) == 1
      assert scorer.name == "John Doe"
      assert scorer.type == :scorer
      assert scorer.license_number == nil
      assert scorer.federation == nil
    end

    test "adds official with license number", %{game_state: game_state} do
      payload = %{
        "name" => "Jane Smith",
        "type" => "timekeeper",
        "license_number" => "TK001"
      }

      event = Event.new("add-official-to-game", "game-123", 600, 1, payload)
      updated_game = AddOfficialToGameDefinition.handle(game_state, event)
      [timekeeper] = updated_game.officials

      assert timekeeper.name == "Jane Smith"
      assert timekeeper.type == :timekeeper
      assert timekeeper.license_number == "TK001"
      assert timekeeper.federation == nil
    end

    test "adds official with all fields", %{game_state: game_state} do
      payload = %{
        "name" => "Mike Johnson",
        "type" => "crew_chief",
        "license_number" => "CC001",
        "federation" => "NBA"
      }

      event = Event.new("add-official-to-game", "game-123", 600, 1, payload)
      updated_game = AddOfficialToGameDefinition.handle(game_state, event)
      [crew_chief] = updated_game.officials
      assert crew_chief.name == "Mike Johnson"
      assert crew_chief.type == :crew_chief
      assert crew_chief.license_number == "CC001"
      assert crew_chief.federation == "NBA"
    end

    test "adds multiple officials of different types", %{game_state: game_state} do
      # Add scorer
      scorer_payload = %{"name" => "John Doe", "type" => "scorer"}
      scorer_event = Event.new("add-official-to-game", "game-123", 600, 1, scorer_payload)
      game_with_scorer = AddOfficialToGameDefinition.handle(game_state, scorer_event)

      # Add timekeeper
      timekeeper_payload = %{"name" => "Jane Smith", "type" => "timekeeper"}
      timekeeper_event = Event.new("add-official-to-game", "game-123", 600, 1, timekeeper_payload)
      game_with_both = AddOfficialToGameDefinition.handle(game_with_scorer, timekeeper_event)
      [timekeeper, scorer] = game_with_both.officials

      assert length(game_with_both.officials) == 2
      assert scorer.name == "John Doe"
      assert timekeeper.name == "Jane Smith"
    end

    test "adds official with provided id (from tournament officials)", %{game_state: game_state} do
      custom_id = Ecto.UUID.generate()

      payload = %{
        "id" => custom_id,
        "name" => "Tournament Official",
        "type" => "crew_chief",
        "license_number" => "CC123",
        "federation" => "FIBA"
      }

      event = Event.new("add-official-to-game", "game-123", 600, 1, payload)
      updated_game = AddOfficialToGameDefinition.handle(game_state, event)
      [official] = updated_game.officials

      assert official.id == custom_id
      assert official.name == "Tournament Official"
      assert official.type == :crew_chief
      assert official.license_number == "CC123"
      assert official.federation == "FIBA"
    end

    test "generates new id when id not provided in payload", %{game_state: game_state} do
      payload = %{
        "name" => "Manual Official",
        "type" => "scorer"
      }

      event = Event.new("add-official-to-game", "game-123", 600, 1, payload)
      updated_game = AddOfficialToGameDefinition.handle(game_state, event)
      [official] = updated_game.officials

      assert official.id != nil
      assert official.name == "Manual Official"
      assert official.type == :scorer
    end
  end

  describe "stream_config/0" do
    test "returns a StreamConfig struct" do
      config = AddOfficialToGameDefinition.stream_config()
      assert %StreamConfig{} = config
    end
  end
end
