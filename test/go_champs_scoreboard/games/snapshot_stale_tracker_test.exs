defmodule GoChampsScoreboard.Games.SnapshotStaleTrackerTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.SnapshotStaleTracker

  setup do
    game_id = "stale-tracker-test-#{:rand.uniform(1_000_000)}"

    on_exit(fn ->
      Redix.command(:games_cache, ["DEL", "snapshot_needs_rebuild:#{game_id}"])
    end)

    %{game_id: game_id}
  end

  describe "needs_rebuild?/1" do
    test "returns false when no flag is set for the game", %{game_id: game_id} do
      refute SnapshotStaleTracker.needs_rebuild?(game_id)
    end

    test "returns true after mark_persisted/1 is called", %{game_id: game_id} do
      SnapshotStaleTracker.mark_persisted(game_id)
      assert SnapshotStaleTracker.needs_rebuild?(game_id)
    end

    test "returns false after mark_rebuilt/1 is called", %{game_id: game_id} do
      SnapshotStaleTracker.mark_persisted(game_id)
      SnapshotStaleTracker.mark_rebuilt(game_id)
      refute SnapshotStaleTracker.needs_rebuild?(game_id)
    end
  end

  describe "mark_persisted/1" do
    test "sets the stale flag for the game", %{game_id: game_id} do
      :ok = SnapshotStaleTracker.mark_persisted(game_id)
      assert SnapshotStaleTracker.needs_rebuild?(game_id)
    end

    test "is idempotent — calling multiple times keeps flag set", %{game_id: game_id} do
      :ok = SnapshotStaleTracker.mark_persisted(game_id)
      :ok = SnapshotStaleTracker.mark_persisted(game_id)
      :ok = SnapshotStaleTracker.mark_persisted(game_id)
      assert SnapshotStaleTracker.needs_rebuild?(game_id)
    end
  end

  describe "mark_rebuilt/1" do
    test "clears the stale flag for the game", %{game_id: game_id} do
      SnapshotStaleTracker.mark_persisted(game_id)
      :ok = SnapshotStaleTracker.mark_rebuilt(game_id)
      refute SnapshotStaleTracker.needs_rebuild?(game_id)
    end

    test "is a no-op when flag is not set", %{game_id: game_id} do
      :ok = SnapshotStaleTracker.mark_rebuilt(game_id)
      refute SnapshotStaleTracker.needs_rebuild?(game_id)
    end

    test "re-marks as stale after mark_rebuilt if mark_persisted is called again", %{
      game_id: game_id
    } do
      SnapshotStaleTracker.mark_persisted(game_id)
      SnapshotStaleTracker.mark_rebuilt(game_id)
      refute SnapshotStaleTracker.needs_rebuild?(game_id)

      SnapshotStaleTracker.mark_persisted(game_id)
      assert SnapshotStaleTracker.needs_rebuild?(game_id)
    end
  end

  describe "flag isolation" do
    test "flags for different game IDs are independent" do
      other_game_id = "other-stale-tracker-test-#{:rand.uniform(1_000_000)}"

      on_exit(fn ->
        Redix.command(:games_cache, ["DEL", "snapshot_needs_rebuild:#{other_game_id}"])
      end)

      SnapshotStaleTracker.mark_persisted(other_game_id)

      # Use a fresh game_id that was not marked
      fresh_game_id = "fresh-stale-tracker-test-#{:rand.uniform(1_000_000)}"

      on_exit(fn ->
        Redix.command(:games_cache, ["DEL", "snapshot_needs_rebuild:#{fresh_game_id}"])
      end)

      refute SnapshotStaleTracker.needs_rebuild?(fresh_game_id)
      assert SnapshotStaleTracker.needs_rebuild?(other_game_id)
    end
  end
end
