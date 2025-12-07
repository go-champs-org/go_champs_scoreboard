defmodule GoChampsScoreboardWeb.EventLogControllerTest do
  use GoChampsScoreboardWeb.ConnCase

  import GoChampsScoreboard.EventsFixtures

  alias GoChampsScoreboard.Games.EventLogs

  @update_payload_attrs %{
    "operation" => "increment",
    "team-type" => "home",
    "player-id" => "123",
    "stat-id" => "rebounds_defensive"
  }
  @invalid_attrs %{
    "operation" => nil,
    "team-type" => nil,
    "player-id" => nil,
    "stat-id" => nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_event_log_with_snapshot]

    test "lists all events pertaning to game id", %{conn: conn, event_log: event_log} do
      conn = get(conn, ~p"/v1/games/#{event_log.game_id}/event-logs")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => event_log.id,
                 "game_id" => event_log.game_id,
                 "key" => event_log.key,
                 "payload" => nil,
                 "timestamp" => event_log.timestamp |> DateTime.to_iso8601(),
                 "game_clock_time" => event_log.game_clock_time,
                 "game_clock_period" => event_log.game_clock_period
               }
             ]
    end

    test "doest not lists events for other games", %{conn: conn, event_log: _event_log} do
      conn = get(conn, ~p"/v1/games/#{Ecto.UUID.generate()}/event-logs")

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "index when there are event_log with different key" do
    setup [:create_event_log_in_the_middle_of_a_game]

    test "list all events pertaning to game id when no query param id provided", %{
      conn: conn,
      event_log: event_log
    } do
      conn = get(conn, ~p"/v1/games/#{event_log.game_id}/event-logs")

      [first_event, second_event, third_event] = EventLogs.get_all_by_game_id(event_log.game_id)

      assert json_response(conn, 200)["data"] == [
               %{
                 "game_clock_period" => third_event.game_clock_period,
                 "game_clock_time" => third_event.game_clock_time,
                 "game_id" => third_event.game_id,
                 "id" => third_event.id,
                 "key" => third_event.key,
                 "payload" => %{
                   "operation" => "increment",
                   "player-id" => "123",
                   "stat-id" => "field_goals_made",
                   "team-type" => "home"
                 },
                 "timestamp" => third_event.timestamp |> DateTime.to_iso8601()
               },
               %{
                 "id" => second_event.id,
                 "game_id" => second_event.game_id,
                 "key" => second_event.key,
                 "payload" => %{
                   "operation" => "increment",
                   "team-type" => "home",
                   "player-id" => "123",
                   "stat-id" => "field_goals_made"
                 },
                 "timestamp" => second_event.timestamp |> DateTime.to_iso8601(),
                 "game_clock_time" => second_event.game_clock_time,
                 "game_clock_period" => second_event.game_clock_period
               },
               %{
                 "id" => first_event.id,
                 "game_id" => first_event.game_id,
                 "key" => first_event.key,
                 "payload" => nil,
                 "timestamp" => first_event.timestamp |> DateTime.to_iso8601(),
                 "game_clock_time" => first_event.game_clock_time,
                 "game_clock_period" => first_event.game_clock_period
               }
             ]
    end

    test "lists all events pertaning to game id an key as query param", %{
      conn: conn,
      event_log: event_log
    } do
      conn = get(conn, ~p"/v1/games/#{event_log.game_id}/event-logs?key=#{event_log.key}")

      assert Enum.all?(json_response(conn, 200)["data"], fn event ->
               event["key"] == event_log.key
             end)
    end

    test "lists events filtered by multiple keys using comma-separated values", %{
      conn: conn,
      event_log: event_log
    } do
      # Get all events to see what keys are available
      all_events = EventLogs.get_all_by_game_id(event_log.game_id)
      available_keys = Enum.map(all_events, & &1.key) |> Enum.uniq()

      # Create a comma-separated string of the first two keys (if available)
      multiple_keys =
        case available_keys do
          [key1, key2 | _] -> "#{key1},#{key2}"
          [key1] -> key1
          [] -> ""
        end

      conn = get(conn, ~p"/v1/games/#{event_log.game_id}/event-logs?key=#{multiple_keys}")
      response_data = json_response(conn, 200)["data"]

      # Verify all returned events have keys that match our filter
      expected_keys = String.split(multiple_keys, ",", trim: true)

      assert Enum.all?(response_data, fn event ->
               event["key"] in expected_keys
             end)
    end
  end

  describe "create" do
    setup [:create_initial_event_log]

    test "creates and renders event_log when data is valid", %{
      conn: conn,
      event_log: first_event_log
    } do
      create_attrs = %{
        "key" => "update-player-stat",
        "game_id" => first_event_log.game_id,
        "game_clock_time" => 5,
        "game_clock_period" => 1,
        "payload" => %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "field_goals_made"
        }
      }

      conn = post(conn, ~p"/v1/event-logs", create_attrs)

      response = json_response(conn, 201)["data"]

      assert response["key"] == "update-player-stat"
      assert response["game_id"] == first_event_log.game_id
      assert response["game_clock_time"] == 5
      assert response["game_clock_period"] == 1

      assert response["payload"] == %{
               "operation" => "increment",
               "team-type" => "home",
               "player-id" => "123",
               "stat-id" => "field_goals_made"
             }

      assert response["id"] != nil
      assert response["timestamp"] != nil
    end

    test "renders errors when required data is missing", %{conn: conn} do
      incomplete_attrs = %{
        "key" => "update-player-stat",
        "game_clock_time" => 550
      }

      conn = post(conn, ~p"/v1/event-logs", incomplete_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when no prior event exists", %{conn: conn} do
      new_game_id = Ecto.UUID.generate()

      create_attrs = %{
        "key" => "update-player-stat",
        "game_id" => new_game_id,
        "game_clock_time" => 550,
        "game_clock_period" => 1,
        "payload" => %{}
      }

      conn = post(conn, ~p"/v1/event-logs", create_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update first event_log" do
    setup [:create_event_log_with_snapshot]

    test "renders errors", %{
      conn: conn,
      event_log: event_log
    } do
      conn = put(conn, ~p"/v1/event-logs/#{event_log.id}", payload: @update_payload_attrs)

      assert json_response(conn, 422)["errors"] == %{"detail" => "Cannot update first event log"}
    end
  end

  describe "update event_log in the middle of the game" do
    setup [:create_event_log_in_the_middle_of_a_game]

    test "renders event_log when data is valid", %{
      conn: conn,
      event_log: event_log
    } do
      conn = put(conn, ~p"/v1/event-logs/#{event_log.id}", payload: @update_payload_attrs)

      game_id = event_log.game_id
      key = event_log.key
      timestamp = event_log.timestamp |> DateTime.to_iso8601()
      game_clock_time = event_log.game_clock_time
      game_clock_period = event_log.game_clock_period

      assert %{
               "game_id" => ^game_id,
               "key" => ^key,
               "payload" => %{
                 "operation" => "increment",
                 "team-type" => "home",
                 "player-id" => "123",
                 "stat-id" => "rebounds_defensive"
               },
               "timestamp" => ^timestamp,
               "game_clock_time" => ^game_clock_time,
               "game_clock_period" => ^game_clock_period
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event_log: event_log} do
      conn = put(conn, ~p"/v1/event-logs/#{event_log.id}", payload: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete first event_log" do
    setup [:create_event_log_with_snapshot]

    test "renders error", %{
      conn: conn,
      event_log: event_log
    } do
      conn = delete(conn, ~p"/v1/event-logs/#{event_log.id}")

      assert json_response(conn, 422)["errors"] == %{"detail" => "Cannot update first event log"}
    end
  end

  describe "delete event_log in the middle of the game" do
    setup [:create_event_log_in_the_middle_of_a_game]

    test "deletes chosen event_log", %{conn: conn, event_log: event_log} do
      conn = delete(conn, ~p"/v1/event-logs/#{event_log.id}")
      assert response(conn, 204)

      conn = get(conn, ~p"/v1/event-logs/#{event_log.id}")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  describe "delete event_log in the end of the game" do
    setup [:create_event_log_with_snapshot_in_end_of_game]

    test "deletes chosen event_log", %{conn: conn, event_log: event_log} do
      conn = delete(conn, ~p"/v1/games/#{event_log.game_id}/event-logs/last")
      assert response(conn, 204)

      conn = get(conn, ~p"/v1/event-logs/#{event_log.id}")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  defp create_event_log_with_snapshot(_) do
    event_log = event_log_with_snapshot_fixture()
    %{event_log: event_log}
  end

  defp create_initial_event_log(_) do
    event_log = event_log_with_snapshot_fixture()
    %{event_log: event_log}
  end

  defp create_event_log_in_the_middle_of_a_game(_) do
    event_log = event_log_with_snapshot_in_middle_of_game_fixture()
    %{event_log: event_log}
  end

  defp create_event_log_with_snapshot_in_end_of_game(_) do
    event_log = event_log_with_snapshot_in_end_of_game_fixture()
    %{event_log: event_log}
  end
end
