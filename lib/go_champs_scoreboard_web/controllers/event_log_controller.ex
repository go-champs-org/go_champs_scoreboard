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
      |> Enum.map(fn {k, v} -> {String.to_atom(k), parse_filter_value(k, v)} end)
      |> Keyword.put_new(:order, :desc)

    event_logs = EventLogs.get_all_by_game_id(game_id, filters)
    render(conn, :index, event_logs: event_logs)
  end

  def show(conn, %{"id" => id}) do
    event_log = EventLogs.get(id)
    render(conn, :show, event_log: event_log)
  end

  def create(conn, params) do
    with {:ok, event_log} <- build_event_log(params),
         {:ok, %EventLog{} = created_event_log} <- EventLogs.add(event_log) do
      conn
      |> put_status(:created)
      |> render(:show, event_log: created_event_log)
    end
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
    EventLogs.get_last_undoable_by_game_id(game_id)
    |> case do
      nil ->
        send_resp(conn, :not_found, "No event log found for game #{game_id}")

      event_log ->
        with {:ok, %EventLog{}} <- EventLogs.delete(event_log.id) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  defp build_event_log(params) do
    required_fields = ["key", "game_id", "game_clock_time", "game_clock_period"]

    case Enum.all?(required_fields, &Map.has_key?(params, &1)) do
      false ->
        {:error, "Missing required fields: #{inspect(required_fields)}"}

      true ->
        event_log = %EventLog{
          key: params["key"],
          game_id: params["game_id"],
          payload: params["payload"] || %{},
          timestamp: DateTime.utc_now(),
          game_clock_time: params["game_clock_time"],
          game_clock_period: params["game_clock_period"]
        }

        {:ok, event_log}
    end
  end

  # Helper function to parse filter values, particularly for the 'key' parameter
  # Supports comma-separated values for multiple keys
  defp parse_filter_value("key", value) when is_binary(value) do
    case String.split(value, ",", trim: true) do
      [single_key] -> single_key
      multiple_keys -> multiple_keys
    end
  end

  defp parse_filter_value(_key, value), do: value
end
