defmodule GoChampsScoreboard.Games.SnapshotStaleTracker do
  @moduledoc """
  Tracks whether a game's DB snapshots are potentially stale.

  `persist/4` in EventLogs is intentionally O(1) and skips `rebuild_all_snapshots`
  for speed during live scoring. This means that after any persist call the stored
  snapshots may no longer reflect the correct cumulative game state.

  This module maintains a lightweight Redis flag per game so that downstream
  mechanisms (the LiveView inactivity timer and the GameSnapshotWatchdog) can decide
  whether an O(n) rebuild is actually necessary before spending the time to do it.

  ## Flag lifecycle

      persist() called
        └─ mark_persisted/1  →  flag = true

      rebuild_all_snapshots/1 succeeds
        └─ mark_rebuilt/1    →  flag deleted

      LiveView inactivity timeout / Watchdog tick
        └─ needs_rebuild?/1  →  true  →  rebuild + mark_rebuilt
                             →  false →  skip (already consistent)
  """

  @two_days_in_seconds 172_800
  @key_prefix "snapshot_needs_rebuild"

  @spec mark_persisted(String.t()) :: :ok | {:error, any()}
  def mark_persisted(game_id) do
    case Redix.command(:games_cache, [
           "SET",
           cache_key(game_id),
           "true",
           "EX",
           @two_days_in_seconds
         ]) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @spec mark_rebuilt(String.t()) :: :ok | {:error, any()}
  def mark_rebuilt(game_id) do
    case Redix.command(:games_cache, ["DEL", cache_key(game_id)]) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @spec needs_rebuild?(String.t()) :: boolean()
  def needs_rebuild?(game_id) do
    case Redix.command(:games_cache, ["EXISTS", cache_key(game_id)]) do
      {:ok, 0} -> false
      _ -> true
    end
  end

  @spec cache_key(String.t()) :: String.t()
  defp cache_key(game_id), do: "#{@key_prefix}:#{game_id}"
end
