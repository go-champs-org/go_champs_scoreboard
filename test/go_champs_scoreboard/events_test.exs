defmodule GoChampsScoreboard.EventsTest do
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Events

  describe "event_logs" do
    alias GoChampsScoreboard.Events.EventLog

    import GoChampsScoreboard.EventsFixtures

    @invalid_attrs %{
      timestamp: nil,
      key: nil,
      payload: nil,
      game_id: nil,
      sequence_number: nil
    }

    test "list_event_logs/0 returns all event_logs" do
      event_log = event_log_fixture()
      assert Events.list_event_logs() == [event_log]
    end

    test "get_event_log!/1 returns the event_log with given id" do
      event_log = event_log_fixture()
      assert Events.get_event_log!(event_log.id) == event_log
    end

    test "create_event_log/1 with valid data creates a event_log" do
      valid_attrs = %{
        timestamp: ~U[2025-04-21 00:39:00.000000Z],
        key: "some key",
        payload: %{},
        game_id: "7488a646-e31f-11e4-aace-600308960662",
        sequence_number: 42
      }

      assert {:ok, %EventLog{} = event_log} = Events.create_event_log(valid_attrs)
      assert event_log.id != nil
      assert event_log.timestamp == ~U[2025-04-21 00:39:00.000000Z]
      assert event_log.key == "some key"
      assert event_log.payload == %{}
      assert event_log.game_id == "7488a646-e31f-11e4-aace-600308960662"
      assert event_log.sequence_number == 42
    end

    test "create_event_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event_log(@invalid_attrs)
    end

    test "update_event_log/2 with valid data updates the event_log" do
      event_log = event_log_fixture()

      update_attrs = %{
        timestamp: ~U[2025-04-22 00:39:00.000000Z],
        key: "some updated key",
        payload: %{},
        game_id: "7488a646-e31f-11e4-aace-600308960668",
        sequence_number: 43
      }

      assert {:ok, %EventLog{} = event_log} = Events.update_event_log(event_log, update_attrs)
      assert event_log.timestamp == ~U[2025-04-22 00:39:00.000000Z]
      assert event_log.key == "some updated key"
      assert event_log.payload == %{}
      assert event_log.game_id == "7488a646-e31f-11e4-aace-600308960668"
      assert event_log.sequence_number == 43
    end

    test "update_event_log/2 with invalid data returns error changeset" do
      event_log = event_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event_log(event_log, @invalid_attrs)
      assert event_log == Events.get_event_log!(event_log.id)
    end

    test "delete_event_log/1 deletes the event_log" do
      event_log = event_log_fixture()
      assert {:ok, %EventLog{}} = Events.delete_event_log(event_log)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_log!(event_log.id) end
    end

    test "change_event_log/1 returns a event_log changeset" do
      event_log = event_log_fixture()
      assert %Ecto.Changeset{} = Events.change_event_log(event_log)
    end
  end
end
