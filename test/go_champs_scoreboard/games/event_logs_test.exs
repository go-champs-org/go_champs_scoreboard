defmodule GoChampsScoreboard.Games.EventLogsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias GoChampsScoreboard.Games.EventLogs

  describe "persist/1" do
    test "persists the event to the database" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
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
          10,
          1,
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
          10,
          1,
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

  describe "delete/1" do
    test "deletes the event log by ID" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
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

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition.create(
          game_id,
          7,
          2,
          %{
            "property" => "time",
            "operation" => "increment"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          2,
          1,
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
          6,
          2,
          %{
            "property" => "period",
            "operation" => "increment"
          }
        )

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          9,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, event1} = EventLogs.persist(event1)
      {:ok, event2} = EventLogs.persist(event2)
      {:ok, event3} = EventLogs.persist(event3)
      {:ok, event4} = EventLogs.persist(event4)

      event_logs = EventLogs.get_all_by_game_id(game_id)

      assert length(event_logs) == 4
      assert Enum.at(event_logs, 0).id == event1.id
      assert Enum.at(event_logs, 0).game_clock_time == 9
      assert Enum.at(event_logs, 0).game_clock_period == 1
      assert Enum.at(event_logs, 1).id == event2.id
      assert Enum.at(event_logs, 1).game_clock_time == 2
      assert Enum.at(event_logs, 1).game_clock_period == 1
      assert Enum.at(event_logs, 2).id == event3.id
      assert Enum.at(event_logs, 2).game_clock_time == 7
      assert Enum.at(event_logs, 2).game_clock_period == 2
      assert Enum.at(event_logs, 3).id == event4.id
      assert Enum.at(event_logs, 3).game_clock_time == 6
      assert Enum.at(event_logs, 3).game_clock_period == 2
    end
  end
end
