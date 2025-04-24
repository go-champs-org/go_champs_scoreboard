defmodule GoChampsScoreboardWeb.EventLogControllerTest do
  use GoChampsScoreboardWeb.ConnCase

  import GoChampsScoreboard.EventsFixtures

  alias GoChampsScoreboard.Events.EventLog

  @create_attrs %{
    timestamp: ~U[2025-04-21 00:39:00.000000Z],
    key: "some key",
    payload: %{},
    game_id: "7488a646-e31f-11e4-aace-600308960662",
    game_clock_time: 10,
    game_clock_period: 1
  }
  @update_attrs %{
    timestamp: ~U[2025-04-22 00:39:00.000000Z],
    key: "some updated key",
    payload: %{},
    game_id: "7488a646-e31f-11e4-aace-600308960668",
    game_clock_time: 20,
    game_clock_period: 2
  }
  @invalid_attrs %{
    id: nil,
    timestamp: nil,
    key: nil,
    payload: nil,
    game_id: nil,
    game_clock_time: nil,
    game_clock_period: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all event_logs", %{conn: conn} do
      conn = get(conn, ~p"/v1/event-logs")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all events pertaning to game id", %{conn: conn} do
      event_log = event_log_fixture()
      conn = get(conn, ~p"/v1/games/#{event_log.game_id}/event-logs")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => event_log.id,
                 "game_id" => "7488a646-e31f-11e4-aace-600308960662",
                 "key" => "some key",
                 "payload" => %{},
                 "timestamp" => "2025-04-21T00:39:00.000000Z",
                 "game_clock_time" => 10,
                 "game_clock_period" => 1
               }
             ]
    end

    test "doest not lists events for other games", %{conn: conn} do
      event_log_fixture()
      conn = get(conn, ~p"/v1/games/#{Ecto.UUID.generate()}/event-logs")

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create event_log" do
    test "renders event_log when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/v1/event-logs", event_log: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/v1/event-logs/#{id}")

      assert %{
               "game_id" => "7488a646-e31f-11e4-aace-600308960662",
               "key" => "some key",
               "payload" => %{},
               "timestamp" => "2025-04-21T00:39:00.000000Z",
               "game_clock_time" => 10,
               "game_clock_period" => 1
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/v1/event-logs", event_log: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event_log" do
    setup [:create_event_log]

    test "renders event_log when data is valid", %{
      conn: conn,
      event_log: %EventLog{id: id} = event_log
    } do
      conn = put(conn, ~p"/v1/event-logs/#{event_log}", event_log: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/v1/event-logs/#{id}")

      assert %{
               "game_id" => "7488a646-e31f-11e4-aace-600308960668",
               "key" => "some updated key",
               "payload" => %{},
               "timestamp" => "2025-04-22T00:39:00.000000Z",
               "game_clock_time" => 20,
               "game_clock_period" => 2
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event_log: event_log} do
      conn = put(conn, ~p"/v1/event-logs/#{event_log}", event_log: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event_log" do
    setup [:create_event_log]

    test "deletes chosen event_log", %{conn: conn, event_log: event_log} do
      conn = delete(conn, ~p"/v1/event-logs/#{event_log}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/v1/event-logs/#{event_log}")
      end
    end
  end

  defp create_event_log(_) do
    event_log = event_log_fixture()
    %{event_log: event_log}
  end
end
