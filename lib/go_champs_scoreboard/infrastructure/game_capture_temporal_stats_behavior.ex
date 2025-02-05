defmodule GoChampsScoreboard.Infrastructure.GameCaptureTemporalStatsSupervisorBehavior do
  @callback check_game_capture_temporal_stats(String.t()) :: :ok | {:error, any()}
  @callback start_game_capture_temporal_stats(String.t()) :: :ok | {:error, any()}
  @callback stop_game_capture_temporal_stats(String.t()) :: :ok | {:error, any()}
end
