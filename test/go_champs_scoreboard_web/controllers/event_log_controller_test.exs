defmodule GoChampsScoreboardWeb.EventLogControllerTest do
  use GoChampsScoreboardWeb.ConnCase

  import GoChampsScoreboard.EventsFixtures

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

  defp create_event_log_with_snapshot(_) do
    event_log = event_log_with_snapshot_fixture()
    %{event_log: event_log}
  end

  defp create_event_log_in_the_middle_of_a_game(_) do
    event_log = event_log_with_snapshot_in_middle_of_game_fixture()
    %{event_log: event_log}
  end
end
