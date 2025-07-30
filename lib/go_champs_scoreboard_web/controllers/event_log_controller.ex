defmodule GoChampsScoreboardWeb.EventLogController do
  use GoChampsScoreboardWeb, :controller

  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Games.EventLogs

  action_fallback GoChampsScoreboardWeb.FallbackController

  def index(conn, params) do
    %{"game_id" => game_id} = params

    filters =
      params
      |> Enum.filter(fn {k, _v} -> k != "game_id" end)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    event_logs = EventLogs.get_all_by_game_id(game_id, filters)
    render(conn, :index, event_logs: event_logs)
  end

  def show(conn, %{"id" => id}) do
    event_log = EventLogs.get(id)
    render(conn, :show, event_log: event_log)
  end

  def update(conn, %{"id" => id, "payload" => payload_params}) do
    with {:ok, %EventLog{} = event_log} <-
           EventLogs.update_payload(id, payload_params) do
      render(conn, :show, event_log: event_log)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %EventLog{}} <- EventLogs.delete(id) do
      send_resp(conn, :no_content, "")
    end
  end

  def delete_last(conn, %{"game_id" => game_id}) do
    EventLogs.get_last_by_game_id(game_id)
    |> case do
      nil ->
        send_resp(conn, :not_found, "No event log found for game #{game_id}")

      event_log ->
        with {:ok, %EventLog{}} <- EventLogs.delete(event_log.id) do
          send_resp(conn, :no_content, "")
        end
    end
  end
end
