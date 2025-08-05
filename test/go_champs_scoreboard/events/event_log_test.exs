defmodule GoChampsScoreboard.Events.EventLogTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.EventLog

  describe "from_json/1" do
    test "deserializes JSON string to EventLog struct" do
      json_string = """
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "key": "update_player_stat",
        "game_id": "456e7890-e89b-12d3-a456-426614174111",
        "timestamp": "2023-10-01T12:00:00.000000Z",
        "payload": {"player_id": 1, "stat": "points", "value": 2},
        "game_clock_time": 120,
        "game_clock_period": 1,
        "inserted_at": "2023-10-01T12:00:00.000000Z",
        "updated_at": "2023-10-01T12:00:00.000000Z"
      }
      """

      result = EventLog.from_json(json_string)

      assert %EventLog{} = result
      assert result.key == "update_player_stat"
      assert result.game_id == "456e7890-e89b-12d3-a456-426614174111"
      assert result.payload == %{"player_id" => 1, "stat" => "points", "value" => 2}
      assert result.game_clock_time == 120
      assert result.game_clock_period == 1
    end

    test "handles DateTime parsing correctly" do
      timestamp = "2023-10-01T15:30:45.123456Z"
      expected_datetime = ~U[2023-10-01 15:30:45.123456Z]

      json_string = """
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "key": "game_start",
        "game_id": "456e7890-e89b-12d3-a456-426614174111",
        "timestamp": "#{timestamp}",
        "payload": {},
        "game_clock_time": 0,
        "game_clock_period": 1,
        "inserted_at": "#{timestamp}",
        "updated_at": "#{timestamp}"
      }
      """

      result = EventLog.from_json(json_string)

      assert %EventLog{} = result
      assert result.timestamp == expected_datetime
      assert result.inserted_at == expected_datetime
      assert result.updated_at == expected_datetime
    end

    test "handles DateTime parsing with different formats" do
      # Test with millisecond precision
      json_string = """
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "key": "game_start",
        "game_id": "456e7890-e89b-12d3-a456-426614174111",
        "timestamp": "2023-10-01T15:30:45.123Z",
        "payload": {},
        "game_clock_time": 0,
        "game_clock_period": 1,
        "inserted_at": "2023-10-01T15:30:45.123Z",
        "updated_at": "2023-10-01T15:30:45.123Z"
      }
      """

      result = EventLog.from_json(json_string)

      assert %EventLog{} = result
      assert %DateTime{} = result.timestamp
      assert %DateTime{} = result.inserted_at
      assert %DateTime{} = result.updated_at
    end

    test "handles invalid DateTime strings gracefully" do
      json_string = """
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "key": "game_start",
        "game_id": "456e7890-e89b-12d3-a456-426614174111",
        "timestamp": "invalid-datetime",
        "payload": {},
        "game_clock_time": 0,
        "game_clock_period": 1,
        "inserted_at": "invalid-datetime",
        "updated_at": "invalid-datetime"
      }
      """

      result = EventLog.from_json(json_string)

      assert %EventLog{} = result
      # Should fallback to original string if parsing fails
      assert result.timestamp == "invalid-datetime"
      assert result.inserted_at == "invalid-datetime"
      assert result.updated_at == "invalid-datetime"
    end

    test "handles complex payload structures" do
      complex_payload = %{
        "player" => %{
          "id" => 1,
          "name" => "John Doe",
          "stats" => %{"points" => 10, "rebounds" => 5}
        },
        "action" => "score",
        "metadata" => ["tag1", "tag2"]
      }

      json_string = """
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "key": "complex_event",
        "game_id": "456e7890-e89b-12d3-a456-426614174111",
        "timestamp": "2023-10-01T12:00:00.000000Z",
        "payload": #{Poison.encode!(complex_payload)},
        "game_clock_time": 300,
        "game_clock_period": 2,
        "inserted_at": "2023-10-01T12:00:00.000000Z",
        "updated_at": "2023-10-01T12:00:00.000000Z"
      }
      """

      result = EventLog.from_json(json_string)

      assert %EventLog{} = result
      assert result.key == "complex_event"
      assert result.payload == complex_payload
      assert result.game_clock_time == 300
      assert result.game_clock_period == 2
    end

    test "handles empty payload" do
      json_string = """
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "key": "simple_event",
        "game_id": "456e7890-e89b-12d3-a456-426614174111",
        "timestamp": "2023-10-01T12:00:00.000000Z",
        "payload": {},
        "game_clock_time": 0,
        "game_clock_period": 1,
        "inserted_at": "2023-10-01T12:00:00.000000Z",
        "updated_at": "2023-10-01T12:00:00.000000Z"
      }
      """

      result = EventLog.from_json(json_string)

      assert %EventLog{} = result
      assert result.key == "simple_event"
      assert result.payload == %{}
    end

    test "raises error for invalid JSON" do
      invalid_json = "{"

      assert_raise Poison.ParseError, fn ->
        EventLog.from_json(invalid_json)
      end
    end
  end

  describe "String.Chars implementation" do
    test "converts EventLog to JSON string" do
      event_log = %EventLog{
        id: "123e4567-e89b-12d3-a456-426614174000",
        key: "test_event",
        game_id: "456e7890-e89b-12d3-a456-426614174111",
        timestamp: ~U[2023-10-01 12:00:00.000000Z],
        payload: %{"test" => "value"},
        game_clock_time: 120,
        game_clock_period: 1,
        inserted_at: ~U[2023-10-01 12:00:00.000000Z],
        updated_at: ~U[2023-10-01 12:00:00.000000Z]
      }

      json_string = to_string(event_log)

      # Should be valid JSON
      parsed = Poison.decode!(json_string)
      assert parsed["key"] == "test_event"
      assert parsed["game_clock_time"] == 120
      assert parsed["payload"] == %{"test" => "value"}
    end
  end

  describe "round-trip serialization" do
    test "from_json and to_string are compatible" do
      original_event = %EventLog{
        id: "123e4567-e89b-12d3-a456-426614174000",
        key: "roundtrip_test",
        game_id: "456e7890-e89b-12d3-a456-426614174111",
        timestamp: ~U[2023-10-01 12:00:00.000000Z],
        payload: %{"player_id" => 1, "points" => 3},
        game_clock_time: 240,
        game_clock_period: 2,
        inserted_at: ~U[2023-10-01 12:00:00.000000Z],
        updated_at: ~U[2023-10-01 12:00:00.000000Z]
      }

      # Convert to JSON string
      json_string = to_string(original_event)

      # Convert back to struct
      restored_event = EventLog.from_json(json_string)

      # Should match original (excluding potential timestamp precision differences)
      assert restored_event.key == original_event.key
      assert restored_event.game_id == original_event.game_id
      assert restored_event.payload == original_event.payload
      assert restored_event.game_clock_time == original_event.game_clock_time
      assert restored_event.game_clock_period == original_event.game_clock_period
    end
  end
end
