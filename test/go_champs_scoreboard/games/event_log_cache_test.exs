defmodule GoChampsScoreboard.Games.EventLogCacheTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.EventLogCache
  alias GoChampsScoreboard.Events.EventLog

  setup do
    game_id = Ecto.UUID.generate()

    EventLogCache.invalidate(game_id)

    on_exit(fn ->
      EventLogCache.invalidate(game_id)
    end)

    %{game_id: game_id}
  end

  describe "get/1" do
    test "returns error when no event logs are cached", %{game_id: game_id} do
      assert EventLogCache.get(game_id) == {:error, :not_found}
    end

    test "returns cached event logs when they exist", %{game_id: game_id} do
      event_logs = create_test_event_logs(game_id, 5)

      :ok = EventLogCache.update(game_id, event_logs)

      {:ok, cached_event_logs} = EventLogCache.get(game_id)

      assert length(cached_event_logs) == 5

      assert Enum.all?(cached_event_logs, fn event_log ->
               event_log.game_id == game_id and is_struct(event_log, EventLog)
             end)
    end
  end

  describe "update/1" do
    test "caches event logs successfully", %{game_id: game_id} do
      event_logs = create_test_event_logs(game_id, 3)

      assert EventLogCache.update(game_id, event_logs) == :ok

      {:ok, cached_event_logs} = EventLogCache.get(game_id)
      assert length(cached_event_logs) == 3
    end

    test "limits cached event logs to last 20", %{game_id: game_id} do
      event_logs = create_test_event_logs(game_id, 25)

      assert EventLogCache.update(game_id, event_logs) == :ok

      {:ok, cached_event_logs} = EventLogCache.get(game_id)
      assert length(cached_event_logs) == 20

      expected_ids = Enum.slice(event_logs, -20, 20) |> Enum.map(& &1.id)
      cached_ids = Enum.map(cached_event_logs, & &1.id)
      assert cached_ids == expected_ids
    end

    test "handles empty event logs list", %{game_id: game_id} do
      assert EventLogCache.update(game_id, []) == :ok

      assert EventLogCache.get(game_id) == {:error, :not_found}
    end
  end

  describe "add_event_log/2" do
    test "adds single event log to cache", %{game_id: game_id} do
      event_log = create_test_event_logs(game_id, 1) |> List.first()

      assert EventLogCache.add_event_log(game_id, event_log) == :ok

      {:ok, cached_event_logs} = EventLogCache.get(game_id)
      assert length(cached_event_logs) == 1
      assert List.first(cached_event_logs).id == event_log.id
    end

    test "maintains 20 event limit when adding", %{game_id: game_id} do
      initial_events = create_test_event_logs(game_id, 20)
      EventLogCache.update(game_id, initial_events)

      new_event = create_test_event_logs(game_id, 1) |> List.first()
      assert EventLogCache.add_event_log(game_id, new_event) == :ok

      {:ok, cached_event_logs} = EventLogCache.get(game_id)
      assert length(cached_event_logs) == 20

      # The new event should be first (most recent)
      assert List.first(cached_event_logs).id == new_event.id
    end
  end

  describe "refresh/1" do
    test "refreshes cache with database event logs", %{game_id: game_id} do
      assert EventLogCache.update(game_id, []) == :ok

      assert EventLogCache.get(game_id) == {:error, :not_found}
    end
  end

  describe "invalidate/1" do
    test "removes event logs from cache", %{game_id: game_id} do
      event_logs = create_test_event_logs(game_id, 3)
      EventLogCache.update(game_id, event_logs)

      assert {:ok, _} = EventLogCache.get(game_id)

      assert EventLogCache.invalidate(game_id) == :ok

      assert EventLogCache.get(game_id) == {:error, :not_found}
    end
  end

  describe "cache key format" do
    test "uses correct Redis key format", %{game_id: game_id} do
      event_logs = create_test_event_logs(game_id, 2)
      EventLogCache.update(game_id, event_logs)

      cache_key = "event_logs_cache:#{game_id}"
      {:ok, result} = Redix.command(:games_cache, ["EXISTS", cache_key])
      assert result == 1
    end
  end

  describe "cache TTL" do
    test "sets correct TTL on cache entries", %{game_id: game_id} do
      event_logs = create_test_event_logs(game_id, 1)
      EventLogCache.update(game_id, event_logs)

      cache_key = "event_logs_cache:#{game_id}"
      {:ok, ttl} = Redix.command(:games_cache, ["TTL", cache_key])

      # Should be close to 2 days (172800 seconds), allowing some margin for execution time
      assert ttl > 172_700
      assert ttl <= 172_800
    end
  end

  # Helper functions
  defp create_test_event_logs(game_id, count) do
    Enum.map(1..count, fn i ->
      %EventLog{
        id: Ecto.UUID.generate(),
        key: "test-event-#{i}",
        game_id: game_id,
        payload: %{"test" => "data-#{i}"},
        timestamp: DateTime.utc_now() |> DateTime.add(i, :second),
        game_clock_time: 600 - i * 10,
        game_clock_period: 1,
        inserted_at: DateTime.utc_now() |> DateTime.add(i, :second),
        updated_at: DateTime.utc_now() |> DateTime.add(i, :second),
        snapshot: %Ecto.Association.NotLoaded{
          __field__: :snapshot,
          __owner__: EventLog
        }
      }
    end)
  end
end
