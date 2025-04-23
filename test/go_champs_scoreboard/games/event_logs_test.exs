defmodule GoChampsScoreboard.Games.EventLogsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias GoChampsScoreboard.Games.EventLogs

  describe "persist/1" do
    test "persists the event to the database" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, event_log} = EventLogs.persist(update_player_stat_event)
      assert event_log.key == "update-player-stat"
      assert event_log.timestamp == update_player_stat_event.timestamp
      assert event_log.game_id == "7488a646-e31f-11e4-aace-600308960668"

      assert event_log.payload == %{
               "operation" => "increment",
               "team-type" => "home",
               "player-id" => "123",
               "stat-id" => "field_goals_made"
             }

      assert event_log.id != nil
      assert event_log.inserted_at != nil
      assert event_log.updated_at != nil
    end
  end

  describe "get/1" do
    test "retrieves the event log by ID" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, event_log} = EventLogs.persist(update_player_stat_event)
      retrieved_event_log = EventLogs.get(event_log.id)

      assert retrieved_event_log.id == event_log.id
      assert retrieved_event_log.key == event_log.key
      assert retrieved_event_log.game_id == event_log.game_id
      assert retrieved_event_log.payload == event_log.payload
    end

    test "returns nil for non-existent event log" do
      assert EventLogs.get("7488a646-e31f-11e4-aace-600308960668") == nil
    end
  end

  describe "update_payload/2" do
    test "updates the event log payload by ID" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, event_log} = EventLogs.persist(update_player_stat_event)

      updated_payload = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds"
      }

      {:ok, updated_event_log} = EventLogs.update_payload(event_log.id, updated_payload)

      assert updated_event_log.payload == updated_payload
    end

    test "returns error for non-existent event log" do
      assert EventLogs.update_payload("7488a646-e31f-11e4-aace-600308960668", %{}) ==
               {:error, :not_found}
    end
  end

  describe "insert_after_event" do
    test "inserts an event after a specific event" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, event_log} = EventLogs.persist(update_player_stat_event)

      new_event =
        GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          %{
            "property" => "time",
            "operation" => "increment"
          }
        )

      {:ok, inserted_event_log} = EventLogs.insert_after_event(event_log.id, new_event)

      assert inserted_event_log.key == new_event.key
      assert inserted_event_log.game_id == new_event.game_id
      assert inserted_event_log.payload == new_event.payload
      assert inserted_event_log.timestamp == DateTime.add(event_log.timestamp, 1, :microsecond)
    end

    test "returns error for non-existent event log" do
      new_event = %{
        key: "new-event",
        game_id: "7488a646-e31f-11e4-aace-600308960668",
        payload: %{"new_key" => "new_value"},
        timestamp: DateTime.utc_now()
      }

      assert EventLogs.insert_after_event("7488a646-e31f-11e4-aace-600308960668", new_event) ==
               {:error, :prior_event_not_found}
    end
  end

  describe "delete/1" do
    test "deletes the event log by ID" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, event_log} = EventLogs.persist(update_player_stat_event)
      assert EventLogs.get(event_log.id) != nil

      EventLogs.delete(event_log.id)
      assert EventLogs.get(event_log.id) == nil
    end
  end

  describe "get_all_by_game_id/1" do
    test "retrieves all event logs for a specific game ID sorted by timestamp" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition.create(
          game_id,
          %{
            "property" => "time",
            "operation" => "increment"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          %{
            "operation" => "decrement",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      event4 =
        GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition.create(
          game_id,
          %{
            "property" => "period",
            "operation" => "increment"
          }
        )

      {:ok, event1} = EventLogs.persist(event1)
      {:ok, event2} = EventLogs.persist(event2)
      {:ok, event3} = EventLogs.insert_after_event(event1.id, event3)
      {:ok, event4} = EventLogs.persist(event4)

      event_logs = EventLogs.get_all_by_game_id(game_id)

      assert length(event_logs) == 4
      assert Enum.at(event_logs, 0).id == event1.id
      assert Enum.at(event_logs, 1).id == event3.id
      assert Enum.at(event_logs, 2).id == event2.id
      assert Enum.at(event_logs, 3).id == event4.id
    end
  end
end
