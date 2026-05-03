defmodule GoChampsScoreboard.Infrastructure.GameSnapshotWatchdogTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Infrastructure.GameSnapshotWatchdog
  alias GoChampsScoreboard.Games.SnapshotStaleTracker
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures

  setup do
    game_id = Ecto.UUID.generate()

    on_exit(fn ->
      Redix.command(:games_cache, ["DEL", "snapshot_needs_rebuild:#{game_id}"])
    end)

    %{game_id: game_id}
  end

  describe "handle_info(:check_staleness)" do
    test "does nothing when needs_rebuild? is false", %{game_id: game_id} do
      refute SnapshotStaleTracker.needs_rebuild?(game_id)

      {:ok, watchdog} = GameSnapshotWatchdog.start_link(game_id)

      send(watchdog, :check_staleness)

      # Allow the message to be processed
      :sys.get_state(watchdog)

      # Flag remains false — no side effects
      refute SnapshotStaleTracker.needs_rebuild?(game_id)

      GenServer.stop(watchdog)
    end

    test "attempts rebuild and logs error when flag is set but game has no events", %{
      game_id: game_id
    } do
      SnapshotStaleTracker.mark_persisted(game_id)
      assert SnapshotStaleTracker.needs_rebuild?(game_id)

      {:ok, watchdog} = GameSnapshotWatchdog.start_link(game_id)

      ExUnit.CaptureLog.capture_log(fn ->
        send(watchdog, :check_staleness)
        :sys.get_state(watchdog)
      end)

      # Rebuild failed (no events) so flag remains set
      assert SnapshotStaleTracker.needs_rebuild?(game_id)

      GenServer.stop(watchdog)
    end

    test "clears stale flag after successful rebuild", %{game_id: game_id} do
      game_state = basketball_game_state_fixture(game_id: game_id)

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, _event_log} = EventLogs.persist(event, game_state)

      # persist sets the flag
      assert SnapshotStaleTracker.needs_rebuild?(game_id)

      {:ok, watchdog} = GameSnapshotWatchdog.start_link(game_id)

      send(watchdog, :check_staleness)
      :sys.get_state(watchdog)

      # Rebuild succeeded — flag must be cleared
      refute SnapshotStaleTracker.needs_rebuild?(game_id)

      GenServer.stop(watchdog)
    end

    test "does not attempt a second rebuild if flag was already cleared", %{game_id: game_id} do
      game_state = basketball_game_state_fixture(game_id: game_id)

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, _event_log} = EventLogs.persist(event, game_state)

      {:ok, watchdog} = GameSnapshotWatchdog.start_link(game_id)

      # First check — rebuilds, clears flag
      send(watchdog, :check_staleness)
      :sys.get_state(watchdog)
      refute SnapshotStaleTracker.needs_rebuild?(game_id)

      # Second check — flag is already clear, no action taken
      send(watchdog, :check_staleness)
      :sys.get_state(watchdog)
      refute SnapshotStaleTracker.needs_rebuild?(game_id)

      GenServer.stop(watchdog)
    end
  end
end
