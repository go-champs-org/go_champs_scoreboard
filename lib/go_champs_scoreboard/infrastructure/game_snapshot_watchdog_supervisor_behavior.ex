defmodule GoChampsScoreboard.Infrastructure.GameSnapshotWatchdogSupervisorBehavior do
  @callback check_game_snapshot_watchdog(String.t()) :: :ok | {:error, any()}
  @callback start_game_snapshot_watchdog(String.t()) :: :ok | {:error, any()}
  @callback stop_game_snapshot_watchdog(String.t()) :: :ok | {:error, any()}
end
