defmodule GoChampsScoreboard.Infrastructure.GameSnapshotWatchdog do
  @moduledoc """
  Background watchdog GenServer that detects stale DB snapshots and triggers a rebuild.

  This is the fallback mechanism for when `ScoreboardControlLive` is not connected
  (browser closed, session expired, etc.). It runs every 5 minutes and checks whether
  the `SnapshotStaleTracker` flag is set for its game. If so, it performs a full
  `rebuild_all_snapshots` and broadcasts `game_last_snapshot_updated` so any live
  subscribers reload their state from the fresh snapshot.

  The LiveView inactivity timer (30s) is the primary trigger; this watchdog only acts
  when no active LiveView has already handled the rebuild.
  """

  use GenServer
  require Logger

  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Games.Messages.PubSub
  alias GoChampsScoreboard.Games.SnapshotStaleTracker

  # 5 minutes
  @check_interval_ms 5 * 60 * 1_000

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  @impl true
  def init(game_id) do
    schedule_check()
    {:ok, %{game_id: game_id}}
  end

  @impl true
  def handle_info(:check_staleness, state) do
    if SnapshotStaleTracker.needs_rebuild?(state.game_id) do
      case EventLogs.rebuild_all_snapshots(state.game_id) do
        :ok ->
          PubSub.broadcast_game_last_snapshot_updated(state.game_id)

        {:error, reason} ->
          Logger.error(
            "[GameSnapshotWatchdog] Rebuild failed for game #{state.game_id}: #{inspect(reason)}"
          )
      end
    end

    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check_staleness, @check_interval_ms)
  end

  defp via_tuple(game_id) do
    {:via, Registry, {GoChampsScoreboard.Infrastructure.GameSnapshotWatchdogRegistry, game_id}}
  end
end
