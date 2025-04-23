defmodule GoChampsScoreboardWeb.EventLogJSON do
  alias GoChampsScoreboard.Events.EventLog

  @doc """
  Renders a list of event_logs.
  """
  def index(%{event_logs: event_logs}) do
    %{data: for(event_log <- event_logs, do: data(event_log))}
  end

  @doc """
  Renders a single event_log.
  """
  def show(%{event_log: event_log}) do
    %{data: data(event_log)}
  end

  defp data(%EventLog{} = event_log) do
    %{
      id: event_log.id,
      game_id: event_log.game_id,
      key: event_log.key,
      timestamp: event_log.timestamp,
      payload: event_log.payload
    }
  end
end
