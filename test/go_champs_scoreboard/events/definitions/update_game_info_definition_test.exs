defmodule GoChampsScoreboard.Events.Definitions.UpdateGameInfoDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, InfoState}
  alias GoChampsScoreboard.Events.Definitions.UpdateGameInfoDefinition

  describe "key/0" do
    test "returns correct key" do
      assert UpdateGameInfoDefinition.key() == "update-game-info"
    end
  end

  describe "validate/2" do
    test "returns :ok with both location and number" do
      payload = %{
        "location" => "Stadium A",
        "number" => "GAME123"
      }

      assert {:ok} = UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns :ok with all fields" do
      payload = %{
        "location" => "Stadium A",
        "number" => "GAME123",
        "game_report" => "Great game today"
      }

      assert {:ok} = UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns :ok with only location" do
      payload = %{
        "location" => "Stadium A"
      }

      assert {:ok} = UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns :ok with only number" do
      payload = %{
        "number" => "GAME123"
      }

      assert {:ok} = UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns :ok with only game_report" do
      payload = %{
        "game_report" => "Excellent match"
      }

      assert {:ok} = UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns error with empty payload" do
      payload = %{}

      assert {:error, "Must provide at least one field: location, number, or game_report"} =
               UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns error with invalid payload type" do
      payload = "invalid"

      assert {:error, "Must provide at least one field: location, number, or game_report"} =
               UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns error with invalid location type" do
      payload = %{
        "location" => 123,
        "number" => "GAME123"
      }

      assert {:error, "Invalid location. Must be a string"} =
               UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns error with invalid number type" do
      payload = %{
        "location" => "Stadium A",
        "number" => 456
      }

      assert {:error, "Invalid number. Must be a string"} =
               UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end

    test "returns error with invalid game_report type" do
      payload = %{
        "location" => "Stadium A",
        "game_report" => 789
      }

      assert {:error, "Invalid game_report. Must be a string"} =
               UpdateGameInfoDefinition.validate(%GameState{}, payload)
    end
  end

  describe "create/4" do
    test "creates event with correct key and payload" do
      payload = %{
        "location" => "Stadium A",
        "number" => "GAME123"
      }

      event = UpdateGameInfoDefinition.create("game-id", 600, 1, payload)

      assert event.key == "update-game-info"
      assert event.game_id == "game-id"
      assert event.clock_state_time_at == 600
      assert event.clock_state_period_at == 1
      assert event.payload == payload
    end
  end

  describe "handle/2" do
    test "updates game info with new location and number" do
      original_datetime = DateTime.utc_now()

      game_state = %GameState{
        id: "game-id",
        info: %InfoState{
          datetime: original_datetime,
          tournament_id: "tournament-1",
          tournament_name: "Tournament Name",
          location: "Old Stadium",
          number: "OLD123"
        }
      }

      event_payload = %{
        "location" => "New Stadium",
        "number" => "NEW456",
        "game_report" => "Amazing game with great plays"
      }

      event = UpdateGameInfoDefinition.create("game-id", 600, 1, event_payload)
      updated_game_state = UpdateGameInfoDefinition.handle(game_state, event)

      # Check that info was updated
      assert updated_game_state.info.location == "New Stadium"
      assert updated_game_state.info.number == "NEW456"
      assert updated_game_state.info.game_report == "Amazing game with great plays"

      # Check that other info fields are preserved
      assert updated_game_state.info.datetime == original_datetime
      assert updated_game_state.info.tournament_id == "tournament-1"
      assert updated_game_state.info.tournament_name == "Tournament Name"

      # Check that other game state fields are preserved
      assert updated_game_state.id == "game-id"
    end

    test "handles empty strings for location and number" do
      game_state = %GameState{
        info: %InfoState{
          datetime: DateTime.utc_now(),
          tournament_id: "tournament-1",
          tournament_name: "Tournament Name",
          location: "Old Stadium",
          number: "OLD123",
          game_report: "Old report"
        }
      }

      event_payload = %{
        "location" => "",
        "number" => "",
        "game_report" => ""
      }

      event = UpdateGameInfoDefinition.create("game-id", 600, 1, event_payload)
      updated_game_state = UpdateGameInfoDefinition.handle(game_state, event)

      assert updated_game_state.info.location == ""
      assert updated_game_state.info.number == ""
      assert updated_game_state.info.game_report == ""
    end

    test "updates only location when number is not provided" do
      original_datetime = DateTime.utc_now()

      game_state = %GameState{
        id: "game-id",
        info: %InfoState{
          datetime: original_datetime,
          tournament_id: "tournament-1",
          tournament_name: "Tournament Name",
          location: "Old Stadium",
          number: "OLD123",
          game_report: "Old report"
        }
      }

      event_payload = %{
        "location" => "New Stadium"
      }

      event = UpdateGameInfoDefinition.create("game-id", 600, 1, event_payload)
      updated_game_state = UpdateGameInfoDefinition.handle(game_state, event)

      # Check that location was updated
      assert updated_game_state.info.location == "New Stadium"
      # Check that number was preserved
      assert updated_game_state.info.number == "OLD123"

      # Check that other info fields are preserved
      assert updated_game_state.info.datetime == original_datetime
      assert updated_game_state.info.tournament_id == "tournament-1"
      assert updated_game_state.info.tournament_name == "Tournament Name"
    end

    test "updates only number when location is not provided" do
      original_datetime = DateTime.utc_now()

      game_state = %GameState{
        id: "game-id",
        info: %InfoState{
          datetime: original_datetime,
          tournament_id: "tournament-1",
          tournament_name: "Tournament Name",
          location: "Old Stadium",
          number: "OLD123",
          game_report: "Old report"
        }
      }

      event_payload = %{
        "number" => "NEW456"
      }

      event = UpdateGameInfoDefinition.create("game-id", 600, 1, event_payload)
      updated_game_state = UpdateGameInfoDefinition.handle(game_state, event)

      # Check that number was updated
      assert updated_game_state.info.number == "NEW456"
      # Check that location was preserved
      assert updated_game_state.info.location == "Old Stadium"

      # Check that other info fields are preserved
      assert updated_game_state.info.datetime == original_datetime
      assert updated_game_state.info.tournament_id == "tournament-1"
      assert updated_game_state.info.tournament_name == "Tournament Name"
    end
  end

  describe "stream_config/0" do
    test "returns default stream config" do
      config = UpdateGameInfoDefinition.stream_config()
      assert config.streamable == false
    end
  end
end
