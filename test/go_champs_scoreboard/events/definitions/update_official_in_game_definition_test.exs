defmodule GoChampsScoreboard.Events.Definitions.UpdateOfficialInGameDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.UpdateOfficialInGameDefinition
  alias GoChampsScoreboard.Events.Models.Event

  alias GoChampsScoreboard.Games.Models.{
    GameState,
    TeamState,
    GameClockState,
    LiveState,
    OfficialState
  }

  alias GoChampsScoreboard.Games.Games
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
      assert UpdateOfficialInGameDefinition.key() == "update-official-in-game"
    end
  end

  describe "validate/2" do
    test "validates any payload (currently returns ok for any input)" do
      assert UpdateOfficialInGameDefinition.validate(nil, %{}) == {:ok}

      assert UpdateOfficialInGameDefinition.validate(nil, %{"id" => Ecto.UUID.generate()}) ==
               {:ok}

      assert UpdateOfficialInGameDefinition.validate(nil, "invalid") == {:ok}
    end
  end

  describe "create/4" do
    test "creates event with correct attributes" do
      payload = %{"id" => Ecto.UUID.generate(), "type" => "scorer", "name" => "Updated Name"}

      event = UpdateOfficialInGameDefinition.create("game-123", 600, 1, payload)

      assert %Event{} = event
      assert event.key == "update-official-in-game"
      assert event.game_id == "game-123"
      assert event.clock_state_time_at == 600
      assert event.clock_state_period_at == 1
      assert event.payload == payload
    end

    test "creates event with all update fields" do
      payload = %{
        "id" => Ecto.UUID.generate(),
        "type" => "scorer",
        "name" => "New Name",
        "license_number" => "CC001",
        "federation" => "NBA"
      }

      event = UpdateOfficialInGameDefinition.create("game-456", 120, 2, payload)

      assert event.game_id == "game-456"
      assert event.clock_state_time_at == 120
      assert event.clock_state_period_at == 2
      assert event.payload == payload
    end
  end

  describe "handle/2" do
    test "updates official name only", %{game_state: game_state} do
      # Add an official first
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "Original Name", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Update only the name (include type for search)
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "name" => "Updated Name"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official.name == "Updated Name"
      assert updated_official.type == :scorer
      assert updated_official.license_number == "SC001"
      assert updated_official.federation == "FIBA"
    end

    test "type field in payload is used for searching, not updating", %{game_state: game_state} do
      # Add an official
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "John Doe", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Try to change type by including it in payload - it should be ignored
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "name" => "Updated Name",
        "license_number" => "SC002"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official.name == "Updated Name"
      assert updated_official.type == :scorer
      assert updated_official.license_number == "SC002"
      assert updated_official.federation == "FIBA"
    end

    test "updates all updatable fields (all except type)", %{game_state: game_state} do
      # Add an official first
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "Original Name", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Update all updatable fields
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "name" => "New Name",
        "license_number" => "CC002",
        "federation" => "NBA"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official.name == "New Name"
      # Type should NOT change
      assert updated_official.type == :scorer
      assert updated_official.license_number == "CC002"
      assert updated_official.federation == "NBA"
    end

    test "updates license_number to empty string", %{game_state: game_state} do
      # Add an official first
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "John Doe", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Update license_number to empty string
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "license_number" => ""
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official.name == "John Doe"
      assert updated_official.type == :scorer
      assert updated_official.license_number == ""
      assert updated_official.federation == "FIBA"
    end

    test "handles non-existent official gracefully (wrong ID)", %{game_state: game_state} do
      non_existent_id = Ecto.UUID.generate()

      payload = %{
        "id" => non_existent_id,
        "type" => "scorer",
        "name" => "New Name"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_state, event)

      # Game state should remain unchanged
      assert updated_game.officials == game_state.officials
      assert length(updated_game.officials) == 0
    end

    test "handles non-existent official gracefully (wrong type)", %{game_state: game_state} do
      # Add an official
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "John Doe", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Try to update with wrong type
      payload = %{
        "id" => original_official.id,
        "type" => "timekeeper",
        "name" => "New Name"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      # Original official should remain unchanged
      original =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert original.name == "John Doe"
      assert length(updated_game.officials) == 1
    end

    test "updates only the specified official when multiple exist", %{game_state: game_state} do
      # Add multiple officials
      official1 = OfficialState.new(Ecto.UUID.generate(), "Official 1", :scorer, "SC001", "FIBA")

      official2 =
        OfficialState.new(Ecto.UUID.generate(), "Official 2", :timekeeper, "TK001", "NBA")

      official3 =
        OfficialState.new(Ecto.UUID.generate(), "Official 3", :crew_chief, "CC001", "FIBA")

      game_with_officials =
        game_state
        |> Games.add_official(official1)
        |> Games.add_official(official2)
        |> Games.add_official(official3)

      # Update only official2
      payload = %{
        "id" => official2.id,
        "type" => "timekeeper",
        "name" => "Updated Official 2",
        "federation" => "FIBA"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_officials, event)

      # Verify only official2 was updated
      updated_official1 = Enum.find(updated_game.officials, fn o -> o.id == official1.id end)

      updated_official2 =
        Enum.find(updated_game.officials, fn o ->
          o.id == official2.id && o.type == :timekeeper
        end)

      updated_official3 = Enum.find(updated_game.officials, fn o -> o.id == official3.id end)

      # Official1 and Official3 should remain unchanged
      assert updated_official1.name == "Official 1"
      assert updated_official1.federation == "FIBA"
      assert updated_official3.name == "Official 3"
      assert updated_official3.federation == "FIBA"

      # Official2 should be updated
      assert updated_official2.name == "Updated Official 2"
      # unchanged
      assert updated_official2.type == :timekeeper
      # unchanged
      assert updated_official2.license_number == "TK001"
      # updated
      assert updated_official2.federation == "FIBA"
    end

    test "preserves other game state properties", %{game_state: game_state} do
      # Add an official first
      official = OfficialState.new(Ecto.UUID.generate(), "Test Official", :scorer)
      game_with_official = Games.add_official(game_state, official)

      payload = %{
        "id" => official.id,
        "type" => "scorer",
        "name" => "Updated Name"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)

      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      # All other properties should remain unchanged
      assert updated_game.id == game_state.id
      assert updated_game.away_team == game_state.away_team
      assert updated_game.home_team == game_state.home_team
      assert updated_game.clock_state == game_state.clock_state
      assert updated_game.sport_id == game_state.sport_id
      assert updated_game.live_state == game_state.live_state
      assert updated_game.view_settings_state == game_state.view_settings_state
    end

    test "handles partial updates correctly", %{game_state: game_state} do
      # Add an official with all fields
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "John Doe", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Update only federation, leave others unchanged
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "federation" => "NBA"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      # unchanged
      assert updated_official.name == "John Doe"
      # unchanged
      assert updated_official.type == :scorer
      # unchanged
      assert updated_official.license_number == "SC001"
      # updated
      assert updated_official.federation == "NBA"
    end

    test "updates official signature", %{game_state: game_state} do
      # Add an official first
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "John Doe", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Update signature
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "signature" => "base64_signature_data"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official.signature == "base64_signature_data"
      # Other fields unchanged
      assert updated_official.name == "John Doe"
      assert updated_official.type == :scorer
    end

    test "clears official signature when nil provided", %{game_state: game_state} do
      # Add an official with existing signature
      original_official = %OfficialState{
        id: Ecto.UUID.generate(),
        name: "John Doe",
        type: :scorer,
        license_number: "SC001",
        federation: "FIBA",
        signature: "existing_signature"
      }

      game_with_official = Games.add_official(game_state, original_official)

      # Clear signature
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "signature" => nil
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official.signature == nil
      # Other fields unchanged
      assert updated_official.name == "John Doe"
      assert updated_official.type == :scorer
    end

    test "updates official with new_id (from tournament officials)", %{game_state: game_state} do
      # Add a manually created official
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "Manual Official", :scorer, nil, nil)

      game_with_official = Games.add_official(game_state, original_official)

      # Update to tournament official with new ID
      tournament_id = Ecto.UUID.generate()

      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "new_id" => tournament_id,
        "name" => "Tournament Official",
        "license_number" => "SC123",
        "federation" => "FIBA"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      # Should not find official with old ID
      old_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert old_official == nil

      # Should find official with new ID
      new_official =
        Enum.find(updated_game.officials, fn o -> o.id == tournament_id && o.type == :scorer end)

      assert new_official != nil
      assert new_official.id == tournament_id
      assert new_official.name == "Tournament Official"
      assert new_official.type == :scorer
      assert new_official.license_number == "SC123"
      assert new_official.federation == "FIBA"
    end

    test "keeps existing id when new_id not provided", %{game_state: game_state} do
      # Add an official
      original_official =
        OfficialState.new(Ecto.UUID.generate(), "Test Official", :scorer, "SC001", "FIBA")

      game_with_official = Games.add_official(game_state, original_official)

      # Update without new_id
      payload = %{
        "id" => original_official.id,
        "type" => "scorer",
        "name" => "Updated Official"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_official, event)

      # Should still find official with original ID
      updated_official =
        Enum.find(updated_game.officials, fn o ->
          o.id == original_official.id && o.type == :scorer
        end)

      assert updated_official != nil
      assert updated_official.id == original_official.id
      assert updated_official.name == "Updated Official"
    end

    test "can have same official ID with different types", %{game_state: game_state} do
      # Add officials with same ID but different types
      shared_id = Ecto.UUID.generate()

      official_scorer =
        %OfficialState{
          id: shared_id,
          name: "Official Name",
          type: :scorer,
          license_number: "SC001",
          federation: "FIBA"
        }

      official_timekeeper =
        %OfficialState{
          id: shared_id,
          name: "Official Name",
          type: :timekeeper,
          license_number: "TK001",
          federation: "FIBA"
        }

      game_with_officials =
        game_state
        |> Games.add_official(official_scorer)
        |> Games.add_official(official_timekeeper)

      # Verify both are in the game state
      assert length(game_with_officials.officials) == 2

      # Update only the scorer
      payload = %{
        "id" => shared_id,
        "type" => "scorer",
        "license_number" => "SC002"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_officials, event)

      # Should still have both officials
      assert length(updated_game.officials) == 2

      # Scorer should be updated
      updated_scorer =
        Enum.find(updated_game.officials, fn o ->
          o.id == shared_id && o.type == :scorer
        end)

      assert updated_scorer.license_number == "SC002"

      # Timekeeper should remain unchanged
      updated_timekeeper =
        Enum.find(updated_game.officials, fn o ->
          o.id == shared_id && o.type == :timekeeper
        end)

      assert updated_timekeeper.license_number == "TK001"
    end

    test "updating timekeeper does not affect scorer with same ID", %{game_state: game_state} do
      # Add officials with same ID but different types
      shared_id = Ecto.UUID.generate()

      official_scorer =
        %OfficialState{
          id: shared_id,
          name: "John Doe",
          type: :scorer,
          license_number: "SC001",
          federation: "FIBA"
        }

      official_timekeeper =
        %OfficialState{
          id: shared_id,
          name: "Jane Smith",
          type: :timekeeper,
          license_number: "TK001",
          federation: "NBA"
        }

      game_with_officials =
        game_state
        |> Games.add_official(official_scorer)
        |> Games.add_official(official_timekeeper)

      # Update timekeeper
      payload = %{
        "id" => shared_id,
        "type" => "timekeeper",
        "name" => "Jane Updated",
        "federation" => "FIBA"
      }

      event = Event.new("update-official-in-game", "game-123", 600, 1, payload)
      updated_game = UpdateOfficialInGameDefinition.handle(game_with_officials, event)

      # Scorer should remain unchanged
      updated_scorer =
        Enum.find(updated_game.officials, fn o ->
          o.id == shared_id && o.type == :scorer
        end)

      assert updated_scorer.name == "John Doe"
      assert updated_scorer.federation == "FIBA"
      assert updated_scorer.license_number == "SC001"

      # Timekeeper should be updated
      updated_timekeeper =
        Enum.find(updated_game.officials, fn o ->
          o.id == shared_id && o.type == :timekeeper
        end)

      assert updated_timekeeper.name == "Jane Updated"
      assert updated_timekeeper.federation == "FIBA"
      assert updated_timekeeper.license_number == "TK001"
    end
  end

  describe "stream_config/0" do
    test "returns a StreamConfig struct" do
      config = UpdateOfficialInGameDefinition.stream_config()
      assert %StreamConfig{} = config
    end
  end
end
