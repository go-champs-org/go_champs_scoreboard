defmodule GoChampsScoreboardWeb.EventLogController do
  use GoChampsScoreboardWeb, :controller

  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Games.EventLogs

  action_fallback GoChampsScoreboardWeb.FallbackController

  def index(conn, %{"game_id" => game_id}) do
    event_logs = EventLogs.get_all_by_game_id(game_id)
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
end
