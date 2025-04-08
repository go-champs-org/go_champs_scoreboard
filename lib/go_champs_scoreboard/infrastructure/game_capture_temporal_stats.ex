defmodule GoChampsScoreboard.Infrastructure.GameCaptureTemporalStats do
  use GenServer
  alias GoChampsScoreboard.Games.TemporalStats
  alias GoChampsScoreboard.Games.Messages.PubSub

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def init(game_id) do
    PubSub.subscribe(game_id)

    {:ok, %{game_id: game_id}}
  end

  def handle_info(
        {:game_reacted_to_event, %{event: event, game_state: game_state}},
        state
      ) do
    if event.impact_temporal_stats do
      TemporalStats.handle(game_state)
    end

    {:noreply, state}
  end

  defp via_tuple(game_id) do
    {:via, Registry,
     {GoChampsScoreboard.Infrastructure.GameCaptureTemporalStatsRegistry, game_id}}
  end
end
