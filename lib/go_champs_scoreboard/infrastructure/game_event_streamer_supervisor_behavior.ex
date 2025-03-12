defmodule GoChampsScoreboard.Infrastructure.GameEventStreamerSupervisorBehavior do
  @callback check_game_event_streamer(String.t()) :: :ok | {:error, any()}
  @callback start_game_event_streamer(String.t()) :: :ok | {:error, any()}
  @callback stop_game_event_streamer(String.t()) :: :ok | {:error, any()}
end
