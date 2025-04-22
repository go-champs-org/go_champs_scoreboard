defmodule GoChampsScoreboardWeb.EventLogController do
  use GoChampsScoreboardWeb, :controller

  alias GoChampsScoreboard.Events
  alias GoChampsScoreboard.Events.EventLog

  action_fallback GoChampsScoreboardWeb.FallbackController

  def index(conn, _params) do
    event_logs = Events.list_event_logs()
    render(conn, :index, event_logs: event_logs)
  end

  def create(conn, %{"event_log" => event_log_params}) do
    with {:ok, %EventLog{} = event_log} <- Events.create_event_log(event_log_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/v1/event_logs/#{event_log}")
      |> render(:show, event_log: event_log)
    end
  end

  def show(conn, %{"id" => id}) do
    event_log = Events.get_event_log!(id)
    render(conn, :show, event_log: event_log)
  end

  def update(conn, %{"id" => id, "event_log" => event_log_params}) do
    event_log = Events.get_event_log!(id)

    with {:ok, %EventLog{} = event_log} <- Events.update_event_log(event_log, event_log_params) do
      render(conn, :show, event_log: event_log)
    end
  end

  def delete(conn, %{"id" => id}) do
    event_log = Events.get_event_log!(id)

    with {:ok, %EventLog{}} <- Events.delete_event_log(event_log) do
      send_resp(conn, :no_content, "")
    end
  end
end
