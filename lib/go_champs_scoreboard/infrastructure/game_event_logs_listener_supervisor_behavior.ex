defmodule GoChampsScoreboard.Infrastructure.GameEventLogsListenerSupervisorBehavior do
  @callback check_game_event_logs_listener(String.t()) :: :ok | {:error, any()}
  @callback start_game_event_logs_listener(String.t()) :: :ok | {:error, any()}
  @callback stop_game_event_logs_listener(String.t()) :: :ok | {:error, any()}
end
