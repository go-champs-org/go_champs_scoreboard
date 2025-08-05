defmodule GoChampsScoreboard.Games.EventLogCache do
  @behaviour GoChampsScoreboard.Games.EventLogCacheBehavior
  alias GoChampsScoreboard.Events.EventLog

  @moduledoc """
  Cache module for storing the last 20 persisted event logs for each game.
  This cache stores event logs without their snapshots to reduce memory usage.
  """

  @doc """
  Gets the last 20 event logs from cache for a given game ID.

  ## Parameters
  - `game_id`: The ID of the game

  ## Returns
  - `{:ok, [EventLog.t()]}` if event logs are found in cache
  - `{:error, :not_found}` if no event logs are cached for the game
  """
  @spec get(String.t()) :: {:ok, [GoChampsScoreboard.Events.EventLog.t()]} | {:error, :not_found}
  def get(game_id) do
    cache_key = build_cache_key(game_id)

    case Redix.command(:games_cache, ["LRANGE", cache_key, "0", "-1"]) do
      {:ok, []} ->
        {:error, :not_found}

      {:ok, event_logs_json} ->
        event_logs =
          event_logs_json
          |> Enum.map(&EventLog.from_json/1)

        {:ok, event_logs}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Adds a single event log to the cache, maintaining the last 20 limit.
  This is more efficient than refreshing the entire cache when persisting new events.

  ## Parameters
  - `game_id`: The ID of the game
  - `event_log`: The new event log to add to cache

  ## Returns
  - `:ok` if the event log was added successfully
  - `{:error, reason}` if there was an error updating the cache
  """
  @spec add_event_log(String.t(), GoChampsScoreboard.Events.EventLog.t()) :: :ok | {:error, any()}
  def add_event_log(game_id, event_log) do
    cache_key = build_cache_key(game_id)
    event_log_string = to_string(event_log)

    # Use pipeline for atomic operations:
    # 1. Add new event to the front of the list
    # 2. Trim to keep only the last 20 events (0-19)
    # 3. Set TTL for 2 days
    case Redix.pipeline(:games_cache, [
           ["LPUSH", cache_key, event_log_string],
           ["LTRIM", cache_key, "0", "19"],
           ["EXPIRE", cache_key, "172800"]
         ]) do
      {:ok, _results} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Updates the cache with the last 20 event logs for a given game ID.
  This replaces the entire cache with the provided event logs.

  ## Parameters
  - `game_id`: The ID of the game
  - `event_logs`: List of event logs to cache (will be limited to last 20)

  ## Returns
  - `:ok` if the cache was updated successfully
  - `{:error, reason}` if there was an error updating the cache
  """
  @spec update(String.t(), [GoChampsScoreboard.Events.EventLog.t()]) :: :ok | {:error, any()}
  def update(game_id, event_logs) do
    cache_key = build_cache_key(game_id)

    case event_logs do
      [] ->
        # For empty list, we'll just delete the key and let get/1 return {:error, :not_found}
        case Redix.command(:games_cache, ["DEL", cache_key]) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end

      events when is_list(events) ->
        # Limit to last 20 events and convert to strings
        limited_events = Enum.take(events, -20)
        event_log_strings = Enum.map(limited_events, &to_string/1)

        # Use pipeline to replace the entire list atomically:
        # 1. Delete existing list
        # 2. Push all events (RPUSH to maintain order - oldest first)
        # 3. Set TTL for 2 days
        pipeline_commands = [
          ["DEL", cache_key],
          ["RPUSH", cache_key] ++ event_log_strings,
          ["EXPIRE", cache_key, "172800"]
        ]

        case Redix.pipeline(:games_cache, pipeline_commands) do
          {:ok, _results} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @doc """
  Refreshes the cache for a given game ID by fetching the last 20 event logs from the database.

  ## Parameters
  - `game_id`: The ID of the game

  ## Returns
  - `:ok` if the cache was refreshed successfully
  - `{:error, reason}` if there was an error refreshing the cache
  """
  @spec refresh(String.t()) :: :ok | {:error, any()}
  def refresh(game_id) do
    event_logs =
      GoChampsScoreboard.Games.EventLogs.get_last_k_by_game_id(game_id, 20, with_snapshot: false)
      |> Enum.reverse()

    case event_logs do
      [] ->
        update(game_id, [])

      event_logs when is_list(event_logs) ->
        update(game_id, event_logs)
    end
  end

  @doc """
  Invalidates the cache for a given game ID.

  ## Parameters
  - `game_id`: The ID of the game

  ## Returns
  - `:ok` if the cache was invalidated successfully
  - `{:error, reason}` if there was an error invalidating the cache
  """
  @spec invalidate(String.t()) :: :ok | {:error, any()}
  def invalidate(game_id) do
    cache_key = build_cache_key(game_id)

    case Redix.command(:games_cache, ["DEL", cache_key]) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  # Private functions

  defp build_cache_key(game_id) do
    "event_logs_cache:#{game_id}"
  end
end
