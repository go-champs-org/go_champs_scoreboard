defmodule GoChampsScoreboard.Games.EventLogsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias Ecto.Repo
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.GameSnapshot
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Games.EventLogCacheMock
  import Mox

  import GoChampsScoreboard.GameStateFixtures

  describe "add/1" do
    test "generates snapshot based on prior event log" do
      # Create a game state fixture
      game_state = basketball_game_state_fixture()

      # Create an event log for the initial game state
      start_game_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          10,
          1,
          %{}
        )

      {:ok, _event_log} = EventLogs.persist(start_game_event, game_state)

      update_player_stat_event_log = %EventLog{
        key: "update-player-stat",
        game_id: game_state.id,
        timestamp: DateTime.utc_now(),
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "field_goals_made"
        },
        game_clock_time: 10,
        game_clock_period: 1
      }

      {:ok, new_event_log} = EventLogs.add(update_player_stat_event_log)
      expected_field_goals_made = 1

      assert new_event_log.key == update_player_stat_event_log.key
      assert new_event_log.game_id == update_player_stat_event_log.game_id

      assert new_event_log.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") == expected_field_goals_made
    end

    test "returns error when no prior event log exists" do
      game_state = basketball_game_state_fixture()

      update_player_stat_event_log = %EventLog{
        key: "update-player-stat",
        game_id: game_state.id,
        timestamp: DateTime.utc_now(),
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "field_goals_made"
        },
        game_clock_time: 10,
        game_clock_period: 1
      }

      assert {:error, :no_prior_event_log} = EventLogs.add(update_player_stat_event_log)
    end

    test "handles chronological event insertion and snapshot updates correctly" do
      game_state = basketball_game_state_fixture()

      event_a =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      game_state_after_a = Handler.handle(game_state, event_a)
      {:ok, _event_log_a} = EventLogs.persist(event_a, game_state_after_a)

      home_player_id = "123"

      event_b =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          500,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player_id,
            "stat-id" => "field_goals_made"
          }
        )

      game_state_after_b = Handler.handle(game_state_after_a, event_b)
      {:ok, event_log_b} = EventLogs.persist(event_b, game_state_after_b)

      away_player_id = "456"

      event_c =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          400,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => away_player_id,
            "stat-id" => "field_goals_made"
          }
        )

      game_state_after_c = Handler.handle(game_state_after_b, event_c)
      {:ok, event_log_c} = EventLogs.persist(event_c, game_state_after_c)

      # EventD: UpdatePlayerStatDefinition for away team player with clock time 550 (inserted later but chronologically earlier)
      event_d_log = %EventLog{
        key: "update-player-stat",
        game_id: game_state.id,
        timestamp: DateTime.utc_now(),
        payload: %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => away_player_id,
          "stat-id" => "field_goals_made"
        },
        game_clock_time: 550,
        game_clock_period: 1
      }

      {:ok, event_log_d} = EventLogs.add(event_d_log)

      # Reload the event logs to get updated snapshots with the snapshot preloaded
      updated_event_log_b =
        EventLogs.get(event_log_b.id, with_snapshot: true)

      updated_event_log_c =
        EventLogs.get(event_log_c.id, with_snapshot: true)

      # Assert eventB snapshot contains the away team player with field_goals_made updated (eventD)
      # EventB should now reflect the state after EventD has been applied chronologically
      assert updated_event_log_b.snapshot.state
             |> get_field_goals_made_from_player_in_game_state(away_player_id, "away") == 1

      # Assert eventC snapshot sums the eventD field_goals_made
      # EventC should now have both EventD and EventC effects
      assert updated_event_log_c.snapshot.state
             |> get_field_goals_made_from_player_in_game_state(away_player_id, "away") == 2

      # Assert the game's last event snapshot has 2 field_goals_made for the away team player
      last_event_log = EventLogs.get_last_by_game_id(game_state.id)

      assert last_event_log.snapshot.state
             |> get_field_goals_made_from_player_in_game_state(away_player_id, "away") == 2

      # Verify home player still has their original stats
      assert updated_event_log_b.snapshot.state
             |> get_field_goals_made_from_player_in_game_state(home_player_id, "home") == 1

      assert updated_event_log_c.snapshot.state
             |> get_field_goals_made_from_player_in_game_state(home_player_id, "home") == 1

      # Verify chronological order is maintained
      all_events = EventLogs.get_all_by_game_id(game_state.id)

      # Events should be ordered: EventA (600), EventD (550), EventB (500), EventC (400)
      assert length(all_events) == 4
      assert Enum.at(all_events, 0).key == "start-game-live-mode"
      assert Enum.at(all_events, 0).game_clock_time == 600
      assert Enum.at(all_events, 1).id == event_log_d.id
      assert Enum.at(all_events, 1).game_clock_time == 550
      assert Enum.at(all_events, 2).id == event_log_b.id
      assert Enum.at(all_events, 2).game_clock_time == 500
      assert Enum.at(all_events, 3).id == event_log_c.id
      assert Enum.at(all_events, 3).game_clock_time == 400
    end

    test "calls refresh_cache_and_broadcast_event_logs after update_subsequent_snapshots" do
      game_state = basketball_game_state_fixture()

      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      {:ok, _start_event_log} = EventLogs.persist(start_event, game_state)

      expect(EventLogCacheMock, :refresh, fn game_id ->
        assert game_id == game_state.id
        :ok
      end)

      expect(EventLogCacheMock, :get, fn game_id ->
        assert game_id == game_state.id
        {:ok, []}
      end)

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_event_logs_updated,
        fn game_id, _recent_events, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_last_snapshot_updated,
        fn game_id, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      event_log_to_add = %EventLog{
        key: "update-player-stat",
        game_id: game_state.id,
        timestamp: DateTime.utc_now(),
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "field_goals_made"
        },
        game_clock_time: 550,
        game_clock_period: 1
      }

      result =
        EventLogs.add(
          event_log_to_add,
          GoChampsScoreboard.Games.Messages.PubSubMock,
          EventLogCacheMock
        )

      assert {:ok, _added_event_log} = result
      verify!(EventLogCacheMock)
      verify!()
    end

    test "calls pub_sub.broadcast_game_last_snapshot_updated after successful add" do
      game_state = basketball_game_state_fixture()

      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      {:ok, _start_event_log} = EventLogs.persist(start_event, game_state)

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_last_snapshot_updated,
        fn game_id, pub_sub_module ->
          assert game_id == game_state.id
          assert pub_sub_module == GoChampsScoreboard.PubSub
          :ok
        end
      )

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_event_logs_updated,
        fn game_id, _recent_events, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      expect(EventLogCacheMock, :refresh, fn _game_id -> :ok end)
      expect(EventLogCacheMock, :get, fn _game_id -> {:ok, []} end)

      event_log_to_add = %EventLog{
        key: "update-player-stat",
        game_id: game_state.id,
        timestamp: DateTime.utc_now(),
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "field_goals_made"
        },
        game_clock_time: 550,
        game_clock_period: 1
      }

      result =
        EventLogs.add(
          event_log_to_add,
          GoChampsScoreboard.Games.Messages.PubSubMock,
          EventLogCacheMock
        )

      assert {:ok, _added_event_log} = result
      verify!()
    end
  end

  describe "persist/1" do
    test "persists the event along with the snapshot to the database" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()
      {:ok, event_log} = EventLogs.persist(update_player_stat_event, game_state)

      game_state_snapshoted =
        event_log.snapshot.state
        |> Poison.encode!()
        |> GameState.from_json()

      assert event_log.key == "update-player-stat"
      assert event_log.timestamp == update_player_stat_event.timestamp
      assert event_log.game_id == "7488a646-e31f-11e4-aace-600308960668"

      assert event_log.payload == %{
               "operation" => "increment",
               "team-type" => "home",
               "player-id" => "123",
               "stat-id" => "field_goals_made"
             }

      assert event_log.id != nil
      assert event_log.inserted_at != nil
      assert event_log.updated_at != nil
      assert game_state_snapshoted == game_state
    end

    test "calls EventLogCache.add_event_log after successful persist" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()

      # Mock EventLogCache.add_event_log to verify it's called
      expect(EventLogCacheMock, :add_event_log, fn game_id, event_log ->
        assert game_id == "7488a646-e31f-11e4-aace-600308960668"
        assert event_log.key == "update-player-stat"
        :ok
      end)

      # Mock EventLogCache.get to simulate the cache retrieval
      expect(EventLogCacheMock, :get, fn game_id ->
        assert game_id == "7488a646-e31f-11e4-aace-600308960668"
        {:ok, []}
      end)

      {:ok, event_log} =
        EventLogs.persist(update_player_stat_event, game_state, EventLogCacheMock)

      assert event_log.key == "update-player-stat"
      # Verify the mock was called
      verify!(EventLogCacheMock)
    end
  end

  describe "delete/1" do
    test "deletes the event log and its associated snapshot from the database" do
      first_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{}
        )

      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()
      {:ok, _first_event_log} = EventLogs.persist(first_event, game_state)
      {:ok, event_log} = EventLogs.persist(update_player_stat_event, game_state)
      {:ok, _delete_event_log} = EventLogs.delete(event_log.id)

      assert EventLogs.get(event_log.id) == nil
      assert GameSnapshot |> Repo.get(event_log.snapshot.id) == nil
    end

    test "deletes the event log and updates all the subsequent event logs" do
      game_state = basketball_game_state_fixture()

      payload_to_increment_field_goals_made = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload_to_increment_field_goals_made
        )

      game_state_for_event1 =
        game_state |> Handler.handle(event1)

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload_to_increment_field_goals_made
        )

      game_state_for_event2 = game_state_for_event1 |> Handler.handle(event2)

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          6,
          1,
          payload_to_increment_field_goals_made
        )

      game_state_for_event3 = game_state_for_event2 |> Handler.handle(event3)

      {:ok, _event_log1} = EventLogs.persist(event1, game_state_for_event1)
      {:ok, event_log2} = EventLogs.persist(event2, game_state_for_event2)
      {:ok, event_log3} = EventLogs.persist(event3, game_state_for_event3)

      {:ok, _delete_event_log} = EventLogs.delete(event_log2.id)

      assert EventLogs.get(event_log2.id) == nil
      assert GameSnapshot |> Repo.get(event_log2.snapshot.id) == nil

      # Check all events for the game
      event_logs = EventLogs.get_all_by_game_id(game_state.id, with_snapshot: true)
      assert length(event_logs) == 2
      assert Enum.at(event_logs, 1).id == event_log3.id
      assert Enum.at(event_logs, 1).key == event_log3.key
      assert Enum.at(event_logs, 1).game_id == event_log3.game_id
      assert Enum.at(event_logs, 1).payload == event_log3.payload

      expected_field_goals_made =
        game_state_for_event3
        |> get_field_goals_made_from_player_in_game_state("123")
        |> (fn field_goals_made ->
              field_goals_made - 1
            end).()

      assert Enum.at(event_logs, 1).snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               expected_field_goals_made
    end

    test "returns an error if the event log does not exist" do
      assert EventLogs.delete(Ecto.UUID.generate()) == {:error, :not_found}
    end

    test "returns an error if the event log is the first of a game" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{}
        )

      {:ok, event_log} = EventLogs.persist(event, game_state)

      assert EventLogs.delete(event_log.id) == {:error, :cannot_update_first_event_log}
    end

    test "calls PubSub.broadcast_game_last_snapshot_updated when event log is successfully deleted" do
      game_state = basketball_game_state_fixture()

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_last_snapshot_updated,
        fn game_id, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_event_logs_updated,
        fn game_id, _recent_events, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      first_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          10,
          1,
          %{}
        )

      # Use a player ID that exists in the basketball fixture
      home_player = List.first(game_state.home_team.players)

      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, _first_event_log} = EventLogs.persist(first_event, game_state)

      updated_game_state = Handler.handle(game_state, update_player_stat_event)
      {:ok, event_log} = EventLogs.persist(update_player_stat_event, updated_game_state)

      # Test that deletion calls PubSub correctly
      result = EventLogs.delete(event_log.id, GoChampsScoreboard.Games.Messages.PubSubMock)

      assert {:ok, _deleted_event_log} = result
      verify!()
    end

    test "calls EventLogCache.refresh after successful delete" do
      first_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{}
        )

      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()
      {:ok, _first_event_log} = EventLogs.persist(first_event, game_state)
      {:ok, event_log} = EventLogs.persist(update_player_stat_event, game_state)

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_last_snapshot_updated,
        fn
          _game_id, _pub_sub ->
            :ok
        end
      )

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_event_logs_updated,
        fn
          _game_id, _recent_events, _pub_sub ->
            :ok
        end
      )

      # Mock EventLogCache.refresh to verify it's called
      expect(EventLogCacheMock, :refresh, fn game_id ->
        assert game_id == "7488a646-e31f-11e4-aace-600308960668"
        :ok
      end)

      # Mock EventLogCache.get to simulate the cache retrieval
      expect(EventLogCacheMock, :get, fn game_id ->
        assert game_id == "7488a646-e31f-11e4-aace-600308960668"
        {:ok, []}
      end)

      result =
        EventLogs.delete(
          event_log.id,
          GoChampsScoreboard.Games.Messages.PubSubMock,
          EventLogCacheMock
        )

      assert {:ok, _deleted_event_log} = result
      verify!(EventLogCacheMock)
    end
  end

  describe "get/1" do
    test "retrieves the event log by ID" do
      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()

      {:ok, event_log} = EventLogs.persist(update_player_stat_event, game_state)
      retrieved_event_log = EventLogs.get(event_log.id)

      assert retrieved_event_log.id == event_log.id
      assert retrieved_event_log.key == event_log.key
      assert retrieved_event_log.game_id == event_log.game_id
      assert retrieved_event_log.payload == event_log.payload
    end

    test "returns nil for non-existent event log" do
      assert EventLogs.get("7488a646-e31f-11e4-aace-600308960668") == nil
    end
  end

  describe "get_all_by_game_id/1" do
    test "retrieves all event logs for a specific game ID sorted by period, time and timestamp" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition.create(
          game_id,
          7,
          2,
          %{
            "property" => "time",
            "operation" => "increment"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          2,
          1,
          %{
            "operation" => "decrement",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      event4 =
        GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition.create(
          game_id,
          6,
          2,
          %{
            "property" => "period",
            "operation" => "increment"
          }
        )

      event5 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          6,
          2,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "rebounds"
          }
        )

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          9,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()
      {:ok, event1} = EventLogs.persist(event1, game_state)
      {:ok, event2} = EventLogs.persist(event2, game_state)
      {:ok, event3} = EventLogs.persist(event3, game_state)
      # Event if event5 was persisted before event4, it should be sorted after event4
      # because event4 has created before event5
      {:ok, event5} = EventLogs.persist(event5, game_state)
      {:ok, event4} = EventLogs.persist(event4, game_state)

      event_logs = EventLogs.get_all_by_game_id(game_id)

      assert length(event_logs) == 5
      assert Enum.at(event_logs, 0).id == event1.id
      assert Enum.at(event_logs, 0).game_clock_time == 9
      assert Enum.at(event_logs, 0).game_clock_period == 1
      assert Enum.at(event_logs, 1).id == event2.id
      assert Enum.at(event_logs, 1).game_clock_time == 2
      assert Enum.at(event_logs, 1).game_clock_period == 1
      assert Enum.at(event_logs, 2).id == event3.id
      assert Enum.at(event_logs, 2).game_clock_time == 7
      assert Enum.at(event_logs, 2).game_clock_period == 2
      assert Enum.at(event_logs, 3).id == event4.id
      assert Enum.at(event_logs, 3).game_clock_time == 6
      assert Enum.at(event_logs, 3).game_clock_period == 2
      assert Enum.at(event_logs, 4).id == event5.id
      assert Enum.at(event_logs, 4).game_clock_time == 6
      assert Enum.at(event_logs, 4).game_clock_period == 2
    end
  end

  describe "get_all_by_game_id/2" do
    test "retrieves all event logs for a specific game ID and filters by event key" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_id,
          10,
          1,
          %{}
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          2,
          1,
          %{
            "operation" => "decrement",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      game_state = game_state_fixture()
      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, _event_log2} = EventLogs.persist(event2, game_state)

      event_logs = EventLogs.get_all_by_game_id(game_id, key: event_log1.key)

      assert length(event_logs) == 1
      assert Enum.at(event_logs, 0).id == event_log1.id
    end

    test "retrieves all event logs for a specific game ID and filters by game_clock_period" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          10,
          2,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      game_state = game_state_fixture()
      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, _event_log2} = EventLogs.persist(event2, game_state)

      event_logs =
        EventLogs.get_all_by_game_id(game_id, game_clock_period: event_log1.game_clock_period)

      assert length(event_logs) == 1
      assert Enum.at(event_logs, 0).id == event_log1.id
    end

    test "retrieves all event logs and associated game snapshots for a specific game ID" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          10,
          2,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      game_state = game_state_fixture()
      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      event_logs = EventLogs.get_all_by_game_id(game_id, with_snapshot: true)

      assert length(event_logs) == 2
      assert Enum.at(event_logs, 0).id == event_log1.id
      assert Enum.at(event_logs, 0).snapshot.state == event_log1.snapshot.state
      assert Enum.at(event_logs, 1).id == event_log2.id
      assert Enum.at(event_logs, 1).snapshot.state == event_log2.snapshot.state
    end

    test "retrieves all event logs for a specific game ID with ascending order (default)" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          9,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          2,
          1,
          %{
            "operation" => "decrement",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      game_state = game_state_fixture()
      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, _event_log2} = EventLogs.persist(event2, game_state)

      # Test default order (ascending)
      event_logs_default = EventLogs.get_all_by_game_id(game_id)
      event_logs_asc = EventLogs.get_all_by_game_id(game_id, order: :asc)

      assert length(event_logs_default) == 2
      assert length(event_logs_asc) == 2

      # Both should have the same order (ascending by default)
      assert Enum.at(event_logs_default, 0).id == Enum.at(event_logs_asc, 0).id
      assert Enum.at(event_logs_default, 1).id == Enum.at(event_logs_asc, 1).id

      # First event should have higher game_clock_time (basketball ordering)
      assert Enum.at(event_logs_default, 0).game_clock_time == 9
      assert Enum.at(event_logs_default, 1).game_clock_time == 2
    end

    test "retrieves all event logs for a specific game ID with descending order" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          9,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          2,
          1,
          %{
            "operation" => "decrement",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      game_state = game_state_fixture()
      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, _event_log2} = EventLogs.persist(event2, game_state)

      # Test descending order
      event_logs_asc = EventLogs.get_all_by_game_id(game_id, order: :asc)
      event_logs_desc = EventLogs.get_all_by_game_id(game_id, order: :desc)

      assert length(event_logs_desc) == 2

      # Descending should be reverse of ascending
      assert Enum.at(event_logs_desc, 0).id == Enum.at(event_logs_asc, 1).id
      assert Enum.at(event_logs_desc, 1).id == Enum.at(event_logs_asc, 0).id

      # First event in descending should have lower game_clock_time
      assert Enum.at(event_logs_desc, 0).game_clock_time == 2
      assert Enum.at(event_logs_desc, 1).game_clock_time == 9
    end

    test "retrieves all event logs with order combined with other filters" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          9,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          2,
          1,
          %{
            "operation" => "decrement",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "rebounds"
          }
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_id,
          5,
          2,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "789",
            "stat-id" => "field_goals_made"
          }
        )

      game_state = game_state_fixture()
      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, _event_log2} = EventLogs.persist(event2, game_state)
      {:ok, _event_log3} = EventLogs.persist(event3, game_state)

      # Test order with game_clock_period filter
      event_logs =
        EventLogs.get_all_by_game_id(game_id,
          game_clock_period: 1,
          order: :desc
        )

      assert length(event_logs) == 2
      # Should only include events from period 1, in descending order
      assert Enum.at(event_logs, 0).game_clock_time == 2
      assert Enum.at(event_logs, 1).game_clock_time == 9

      # Test order with key filter
      filtered_events =
        EventLogs.get_all_by_game_id(game_id,
          key: "update-player-stat",
          order: :desc,
          with_snapshot: true
        )

      assert length(filtered_events) == 3
      assert Enum.at(filtered_events, 0).snapshot != nil
      assert Enum.at(filtered_events, 1).snapshot != nil
      assert Enum.at(filtered_events, 2).snapshot != nil
    end
  end

  describe "get_first_created_by_game_id/1" do
    test "retrieves the first event log with game snapshot for a specific game ID" do
      game_state = game_state_fixture()

      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          1,
          1,
          %{}
        )

      # Add a small delay to ensure different timestamps
      :timer.sleep(10)

      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, first_event_log} = EventLogs.persist(start_live_event, game_state)
      {:ok, _second_event_log} = EventLogs.persist(update_player_stat_event, game_state)
      {:ok, _third_event_log} = EventLogs.persist(update_player_stat_event, game_state)

      retrieved_event_log = EventLogs.get_first_created_by_game_id(game_state.id)

      assert retrieved_event_log.id == first_event_log.id
      assert retrieved_event_log.key == first_event_log.key
      assert retrieved_event_log.game_id == first_event_log.game_id
      assert retrieved_event_log.payload == first_event_log.payload

      assert retrieved_event_log.snapshot.state ==
               first_event_log.snapshot.state
               |> Poison.encode!()
               |> GameState.from_json()
    end

    test "retrieves the first event log no matter the time they were persisted" do
      game_state = game_state_fixture()

      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          1,
          1,
          %{}
        )

      update_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          10,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, _second_event_log} = EventLogs.persist(update_player_stat_event, game_state)
      {:ok, first_event_log} = EventLogs.persist(start_live_event, game_state)

      retrieved_event_log = EventLogs.get_first_created_by_game_id(game_state.id)

      assert retrieved_event_log.id == first_event_log.id
    end

    test "returns nil for non-existent game ID" do
      assert EventLogs.get_first_created_by_game_id(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_last_by_game_id/1" do
    test "retrieves the last event log with game snapshot for a specific game ID" do
      game_state = basketball_game_state_fixture()

      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      update_home_player_stat_event_second_period =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          300,
          2,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      update_home_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          300,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      update_away_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          200,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "field_goals_made"
          }
        )

      {:ok, _first_event_log} = EventLogs.persist(start_live_event, game_state)

      {:ok, last_game_event_log} =
        EventLogs.persist(update_home_player_stat_event_second_period, game_state)

      {:ok, _middle_event_log} = EventLogs.persist(update_home_player_stat_event, game_state)

      {:ok, _last_persisted_event_log} =
        EventLogs.persist(update_away_player_stat_event, game_state)

      retrieved_event_log = EventLogs.get_last_by_game_id(game_state.id)

      assert retrieved_event_log.id == last_game_event_log.id
      assert retrieved_event_log.key == last_game_event_log.key
      assert retrieved_event_log.game_id == last_game_event_log.game_id
      assert retrieved_event_log.payload == last_game_event_log.payload

      assert retrieved_event_log.snapshot.state ==
               last_game_event_log.snapshot.state
               |> Poison.encode!()
               |> GameState.from_json()
    end

    test "returns nil for non-existent game ID" do
      assert EventLogs.get_last_by_game_id(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_last_k_by_game_id/3" do
    test "retrieves the last k event logs for a basketball game" do
      game_state = basketball_game_state_fixture()

      # Use valid player IDs from the fixture
      home_player = List.first(game_state.home_team.players)
      away_player = List.first(game_state.away_team.players)

      # Create 5 events in order (oldest to newest)
      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      first_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          590,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      game_tick_event =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          580,
          1,
          %{}
        )

      second_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          570,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => away_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      team_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          560,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "timeouts"
          }
        )

      # Persist all events in chronological order
      {:ok, _start_event_log} = EventLogs.persist(start_live_event, game_state)

      updated_game_state1 = Handler.handle(game_state, start_live_event)

      {:ok, _first_stat_event_log} =
        EventLogs.persist(first_player_stat_event, updated_game_state1)

      updated_game_state2 = Handler.handle(updated_game_state1, first_player_stat_event)
      {:ok, tick_event_log} = EventLogs.persist(game_tick_event, updated_game_state2)

      updated_game_state3 = Handler.handle(updated_game_state2, game_tick_event)

      {:ok, second_stat_event_log} =
        EventLogs.persist(second_player_stat_event, updated_game_state3)

      updated_game_state4 = Handler.handle(updated_game_state3, second_player_stat_event)
      {:ok, team_stat_event_log} = EventLogs.persist(team_stat_event, updated_game_state4)

      # Test getting last 3 events
      last_3_events = EventLogs.get_last_k_by_game_id(game_state.id, 3)

      assert length(last_3_events) == 3

      # Should return the last 3 events in chronological order (oldest to newest)
      # Chronological order: start → first_stat → tick → second_stat → team_stat
      # Last 3 events should be: tick, second_stat, team_stat
      expected_ids = [tick_event_log.id, second_stat_event_log.id, team_stat_event_log.id]
      actual_ids = Enum.map(last_3_events, & &1.id)

      assert actual_ids == expected_ids
    end

    test "retrieves all events when k is greater than total events" do
      game_state = basketball_game_state_fixture()

      # Create only 2 events
      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      tick_event =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          590,
          1,
          %{}
        )

      {:ok, start_event_log} = EventLogs.persist(start_event, game_state)
      updated_game_state = Handler.handle(game_state, start_event)
      {:ok, tick_event_log} = EventLogs.persist(tick_event, updated_game_state)

      # Request 5 events but only 2 exist
      events = EventLogs.get_last_k_by_game_id(game_state.id, 5)

      assert length(events) == 2
      assert Enum.map(events, & &1.id) == [start_event_log.id, tick_event_log.id]
    end

    test "returns empty list when k is 0" do
      game_state = basketball_game_state_fixture()

      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      {:ok, _event_log} = EventLogs.persist(start_event, game_state)

      events = EventLogs.get_last_k_by_game_id(game_state.id, 0)

      assert events == []
    end

    test "returns empty list for non-existent game ID" do
      events = EventLogs.get_last_k_by_game_id(Ecto.UUID.generate(), 5)
      assert events == []
    end

    test "returns empty list when no events exist for the game" do
      game_id = Ecto.UUID.generate()
      events = EventLogs.get_last_k_by_game_id(game_id, 3)
      assert events == []
    end

    test "preloads snapshots when with_snapshot option is true" do
      game_state = basketball_game_state_fixture()

      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      {:ok, _event_log} = EventLogs.persist(start_event, game_state)

      # Test without snapshots
      events_without_snapshots =
        EventLogs.get_last_k_by_game_id(game_state.id, 1, with_snapshot: false)

      first_event = List.first(events_without_snapshots)

      # Snapshot should not be loaded (it's an Ecto.Association.NotLoaded struct)
      assert %Ecto.Association.NotLoaded{} = first_event.snapshot

      # Test with snapshots
      events_with_snapshots =
        EventLogs.get_last_k_by_game_id(game_state.id, 1, with_snapshot: true)

      first_event_with_snapshot = List.first(events_with_snapshots)

      # Snapshot should be loaded and processed
      assert first_event_with_snapshot.snapshot != nil
      assert first_event_with_snapshot.snapshot.state != nil
      assert is_struct(first_event_with_snapshot.snapshot.state, GameState)
    end

    test "handles single event correctly" do
      game_state = basketball_game_state_fixture()

      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      {:ok, event_log} = EventLogs.persist(start_event, game_state)

      # Request last 1 event
      events = EventLogs.get_last_k_by_game_id(game_state.id, 1)

      assert length(events) == 1
      assert List.first(events).id == event_log.id
      assert List.first(events).key == "start-game-live-mode"
    end

    test "maintains correct chronological order" do
      game_state = basketball_game_state_fixture()

      # Create events with different game clock times to ensure proper ordering
      event1 =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          # First period, 600 seconds
          600,
          1,
          %{}
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          # First period, 590 seconds (later in time)
          590,
          1,
          %{}
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          # Second period, 600 seconds (even later)
          600,
          2,
          %{}
        )

      # Persist events
      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      updated_state1 = Handler.handle(game_state, event1)

      {:ok, event_log2} = EventLogs.persist(event2, updated_state1)
      updated_state2 = Handler.handle(updated_state1, event2)

      {:ok, event_log3} = EventLogs.persist(event3, updated_state2)

      # Get last 2 events
      events = EventLogs.get_last_k_by_game_id(game_state.id, 2)

      assert length(events) == 2

      # Events should be in chronological order (oldest to newest)
      # Function should return the last 2 events from chronological order
      # Chronological order: event1 → event2 → event3
      # Last 2 events should be: event2, event3
      assert Enum.map(events, & &1.id) == [event_log2.id, event_log3.id]

      # Verify they are indeed in the right chronological order
      first_event = List.first(events)
      second_event = List.last(events)

      assert first_event.game_clock_period <= second_event.game_clock_period

      # If same period, later event should have lower clock time (countdown)
      if first_event.game_clock_period == second_event.game_clock_period do
        assert first_event.game_clock_time >= second_event.game_clock_time
      end
    end

    test "handles different event types correctly" do
      game_state = basketball_game_state_fixture()
      home_player = List.first(game_state.home_team.players)

      # Create different types of events
      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          590,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      team_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          580,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "timeouts"
          }
        )

      # Persist all events
      {:ok, _start_log} = EventLogs.persist(start_event, game_state)

      updated_state1 = Handler.handle(game_state, start_event)
      {:ok, _player_log} = EventLogs.persist(player_stat_event, updated_state1)

      updated_state2 = Handler.handle(updated_state1, player_stat_event)
      {:ok, _team_log} = EventLogs.persist(team_stat_event, updated_state2)

      # Get all 3 events
      events = EventLogs.get_last_k_by_game_id(game_state.id, 3)

      assert length(events) == 3

      # Verify event types
      event_keys = Enum.map(events, & &1.key)
      assert "start-game-live-mode" in event_keys
      assert "update-player-stat" in event_keys
      assert "update-team-stat" in event_keys

      # Verify each event has the correct structure
      Enum.each(events, fn event ->
        assert event.id != nil
        assert event.key != nil
        assert event.game_id == game_state.id
        # Payload can be nil, empty map, or have actual content
        assert is_nil(event.payload) or is_map(event.payload)
        assert event.timestamp != nil
        assert event.game_clock_time != nil
        assert event.game_clock_period != nil
      end)
    end
  end

  describe "get_last_undoable_by_game_id/1" do
    test "retrieves the last undoable event log for a basketball game" do
      game_state = basketball_game_state_fixture()

      # Use valid player IDs from the fixture
      home_player = List.first(game_state.home_team.players)
      away_player = List.first(game_state.away_team.players)

      # Create a start event (not undoable)
      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      # Create update player stat events (undoable)
      update_home_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          300,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      update_away_player_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          200,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => away_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      # Create a game tick event (not undoable)
      game_tick_event =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          100,
          1,
          %{}
        )

      # Create another undoable event - this should be the last undoable one
      last_undoable_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          50,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "rebounds_defensive"
          }
        )

      last_not_undoable_event =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          25,
          1,
          %{}
        )

      # Persist events in chronological order
      {:ok, _start_event_log} = EventLogs.persist(start_live_event, game_state)

      updated_game_state1 = Handler.handle(game_state, update_home_player_stat_event)

      {:ok, _home_stat_event_log} =
        EventLogs.persist(update_home_player_stat_event, updated_game_state1)

      updated_game_state2 = Handler.handle(updated_game_state1, update_away_player_stat_event)

      {:ok, _away_stat_event_log} =
        EventLogs.persist(update_away_player_stat_event, updated_game_state2)

      updated_game_state3 = Handler.handle(updated_game_state2, game_tick_event)
      {:ok, _tick_event_log} = EventLogs.persist(game_tick_event, updated_game_state3)

      updated_game_state4 = Handler.handle(updated_game_state3, last_undoable_event)

      {:ok, expected_last_undoable_log} =
        EventLogs.persist(last_undoable_event, updated_game_state4)

      updated_game_state5 = Handler.handle(updated_game_state4, last_not_undoable_event)

      {:ok, _last_not_undoable_event_log} =
        EventLogs.persist(last_not_undoable_event, updated_game_state5)

      # The function should return the last undoable event, not the game tick
      retrieved_event_log = EventLogs.get_last_undoable_by_game_id(game_state.id)

      assert retrieved_event_log.id == expected_last_undoable_log.id
      assert retrieved_event_log.key == "update-player-stat"
      assert retrieved_event_log.game_id == game_state.id
      assert retrieved_event_log.payload == last_undoable_event.payload
      assert retrieved_event_log.snapshot != nil
    end

    test "returns nil when no undoable events exist for a basketball game" do
      game_state = basketball_game_state_fixture()

      # Create only non-undoable events
      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      game_tick_event =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          500,
          1,
          %{}
        )

      {:ok, _start_event_log} = EventLogs.persist(start_live_event, game_state)

      updated_game_state = Handler.handle(game_state, game_tick_event)
      {:ok, _tick_event_log} = EventLogs.persist(game_tick_event, updated_game_state)

      # Should return nil since no undoable events exist
      retrieved_event_log = EventLogs.get_last_undoable_by_game_id(game_state.id)

      assert retrieved_event_log == nil
    end

    test "returns nil for non-existent game ID" do
      assert EventLogs.get_last_undoable_by_game_id(Ecto.UUID.generate()) == nil
    end

    test "returns nil when no events exist for the game" do
      game_id = Ecto.UUID.generate()
      assert EventLogs.get_last_undoable_by_game_id(game_id) == nil
    end

    test "handles team stat updates as undoable events" do
      game_state = basketball_game_state_fixture()

      # Create a start event
      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      # Create an update team stat event (should be undoable)
      update_team_stat_event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          300,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "timeouts"
          }
        )

      {:ok, _start_event_log} = EventLogs.persist(start_live_event, game_state)

      updated_game_state = Handler.handle(game_state, update_team_stat_event)

      {:ok, expected_team_stat_log} =
        EventLogs.persist(update_team_stat_event, updated_game_state)

      retrieved_event_log = EventLogs.get_last_undoable_by_game_id(game_state.id)

      assert retrieved_event_log.id == expected_team_stat_log.id
      assert retrieved_event_log.key == "update-team-stat"
      assert retrieved_event_log.game_id == game_state.id
      assert retrieved_event_log.payload == update_team_stat_event.payload
    end

    test "returns the most recent undoable event when mixed with non-undoable events" do
      game_state = basketball_game_state_fixture()
      home_player = List.first(game_state.home_team.players)

      # Mix of undoable and non-undoable events
      start_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      first_undoable =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          500,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "field_goals_made"
          }
        )

      non_undoable_tick =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          400,
          1,
          %{}
        )

      second_undoable =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          300,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "stat-id" => "timeouts"
          }
        )

      another_non_undoable =
        GoChampsScoreboard.Events.Definitions.GameTickDefinition.create(
          game_state.id,
          200,
          1,
          %{}
        )

      # Persist all events
      {:ok, _} = EventLogs.persist(start_event, game_state)

      updated_state1 = Handler.handle(game_state, first_undoable)
      {:ok, _} = EventLogs.persist(first_undoable, updated_state1)

      updated_state2 = Handler.handle(updated_state1, non_undoable_tick)
      {:ok, _} = EventLogs.persist(non_undoable_tick, updated_state2)

      updated_state3 = Handler.handle(updated_state2, second_undoable)
      {:ok, expected_last_undoable} = EventLogs.persist(second_undoable, updated_state3)

      updated_state4 = Handler.handle(updated_state3, another_non_undoable)
      {:ok, _} = EventLogs.persist(another_non_undoable, updated_state4)

      # Should return the second undoable event, not the last persisted event
      retrieved_event_log = EventLogs.get_last_undoable_by_game_id(game_state.id)

      assert retrieved_event_log.id == expected_last_undoable.id
      assert retrieved_event_log.key == "update-team-stat"
    end
  end

  describe "get_prior/1" do
    test "retrieves the event log prior to a specific event log with the its associated parsed game snapshot" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload1
        )

      event2_game_state = %{
        game_state
        | away_team: %{
            game_state.away_team
            | players: [
                %{
                  id: "456",
                  stats_values: %{"rebounds_defensive" => 0}
                }
              ]
          }
      }

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload2
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, event2_game_state)

      retrieved_event_log = EventLogs.get_prior(event_log2)

      assert retrieved_event_log.id == event_log1.id
      assert retrieved_event_log.key == event_log1.key
      assert retrieved_event_log.game_id == event_log1.game_id
      assert retrieved_event_log.payload == event_log1.payload

      assert retrieved_event_log.snapshot.state ==
               event_log1.snapshot.state
               |> Poison.encode!()
               |> GameState.from_json()
    end

    test "returns nil if no prior event log exists" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload
        )

      {:ok, event_log} = EventLogs.persist(event, game_state)
      # Attempt to retrieve the prior event log for the first event log
      retrieved_event_log = EventLogs.get_prior(event_log)
      # Since this is the first event log, it should return nil
      assert retrieved_event_log == nil
    end
  end

  describe "get_next/1" do
    test "retrieves the event log after a specific event log with the its associated parsed game snapshot" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload1
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload2
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      retrieved_event_log = EventLogs.get_next(event_log1)

      assert retrieved_event_log.id == event_log2.id
      assert retrieved_event_log.key == event_log2.key
      assert retrieved_event_log.game_id == event_log2.game_id
      assert retrieved_event_log.payload == event_log2.payload

      assert retrieved_event_log.snapshot.state ==
               event_log2.snapshot.state
               |> Poison.encode!()
               |> GameState.from_json()
    end

    test "returns nil if no next event log exists" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload
        )

      {:ok, event_log} = EventLogs.persist(event, game_state)
      # Attempt to retrieve the next event log for the last event log
      retrieved_event_log = EventLogs.get_next(event_log)
      # Since this is the last event log, it should return nil
      assert retrieved_event_log == nil
    end
  end

  describe "subsequent_event_logs/2" do
    test "filters out all event logs prior than the given event_log" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload1
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload2
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      retrieved_event_logs = EventLogs.subsequent_event_logs([event_log1, event_log2], event_log1)

      assert length(retrieved_event_logs) == 1
      assert Enum.at(retrieved_event_logs, 0).id == event_log2.id
      assert Enum.at(retrieved_event_logs, 0).key == event_log2.key
      assert Enum.at(retrieved_event_logs, 0).game_id == event_log2.game_id
      assert Enum.at(retrieved_event_logs, 0).payload == event_log2.payload
    end

    test "retrieves all event logs until the last event log after s specific event log" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      payload3 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload4 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload1
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload2
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          6,
          1,
          payload3
        )

      event4 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          5,
          1,
          payload4
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)
      {:ok, event_log3} = EventLogs.persist(event3, game_state)
      {:ok, event_log4} = EventLogs.persist(event4, game_state)

      retrieved_event_logs =
        EventLogs.subsequent_event_logs(
          [event_log1, event_log2, event_log3, event_log4],
          event_log2
        )

      assert length(retrieved_event_logs) == 2
      assert Enum.at(retrieved_event_logs, 0).id == event_log3.id
      assert Enum.at(retrieved_event_logs, 0).key == event_log3.key
      assert Enum.at(retrieved_event_logs, 0).game_id == event_log3.game_id
      assert Enum.at(retrieved_event_logs, 0).payload == event_log3.payload
      assert Enum.at(retrieved_event_logs, 1).id == event_log4.id
      assert Enum.at(retrieved_event_logs, 1).key == event_log4.key
      assert Enum.at(retrieved_event_logs, 1).game_id == event_log4.game_id
      assert Enum.at(retrieved_event_logs, 1).payload == event_log4.payload
    end

    test "retrieves all event logs until the last event log if given event log is nil" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload1
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload2
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      # Attempt to retrieve all event logs if given event log is nil
      retrieved_event_logs = EventLogs.subsequent_event_logs([event_log1, event_log2], nil)

      assert length(retrieved_event_logs) == 2
      assert Enum.at(retrieved_event_logs, 0).id == event_log1.id
      assert Enum.at(retrieved_event_logs, 0).key == event_log1.key
      assert Enum.at(retrieved_event_logs, 0).game_id == event_log1.game_id
      assert Enum.at(retrieved_event_logs, 0).payload == event_log1.payload
      assert Enum.at(retrieved_event_logs, 1).id == event_log2.id
      assert Enum.at(retrieved_event_logs, 1).key == event_log2.key
      assert Enum.at(retrieved_event_logs, 1).game_id == event_log2.game_id
      assert Enum.at(retrieved_event_logs, 1).payload == event_log2.payload
    end

    test "returns an empty list if no event logs exist after the specified event log" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload1
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload2
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      # Attempt to retrie ve event logs after the last event log
      retrieved_event_logs = EventLogs.subsequent_event_logs([event_log1, event_log2], event_log2)

      assert retrieved_event_logs == []
    end
  end

  describe "update_payload/2" do
    test "updates the payload and current and subsequent snapshots" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          10,
          1,
          payload
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          9,
          1,
          payload
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload
        )

      game_state_for_event1 =
        game_state |> Handler.handle(event1)

      game_state_for_event2 =
        game_state_for_event1 |> Handler.handle(event2)

      game_state_for_event3 =
        game_state_for_event2 |> Handler.handle(event3)

      {:ok, event_log1} = EventLogs.persist(event1, game_state_for_event1)
      {:ok, event_log2} = EventLogs.persist(event2, game_state_for_event2)
      {:ok, event_log3} = EventLogs.persist(event3, game_state_for_event3)

      assert event_log1.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               1

      assert event_log1.snapshot.state
             |> get_rebounds_defensive_from_player_in_game_state("123") == 0

      assert event_log2.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               2

      assert event_log2.snapshot.state
             |> get_rebounds_defensive_from_player_in_game_state("123") == 0

      assert event_log3.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               3

      assert event_log3.snapshot.state
             |> get_rebounds_defensive_from_player_in_game_state("123") == 0

      new_payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "rebounds_defensive"
      }

      # Instead a field goal it was a defensive rebound on the event 2
      {:ok, updated_event_log} = EventLogs.update_payload(event_log2.id, new_payload)

      assert updated_event_log.payload == new_payload

      [updated_event_log1, updated_event_log2, updated_event_log3] =
        EventLogs.get_all_by_game_id(game_state.id, with_snapshot: true)

      assert updated_event_log1.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               1

      assert updated_event_log1.snapshot.state
             |> get_rebounds_defensive_from_player_in_game_state("123") == 0

      # It should now have 1 field goal made and 1 defensive rebounds
      assert updated_event_log2.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               1

      assert updated_event_log2.snapshot.state
             |> get_rebounds_defensive_from_player_in_game_state("123") == 1

      # It should now have 2 field goals made and 1 defensive rebound
      assert updated_event_log3.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               2

      assert updated_event_log3.snapshot.state
             |> get_rebounds_defensive_from_player_in_game_state("123") == 1
    end

    test "returns an error if the event log does not exist" do
      new_payload = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      assert EventLogs.update_payload(Ecto.UUID.generate(), new_payload) ==
               {:error, :not_found}
    end

    test "returns an error if the event log is the first" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload
        )

      {:ok, event_log} = EventLogs.persist(event, game_state)

      new_payload = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "rebounds_defensive"
      }

      assert EventLogs.update_payload(event_log.id, new_payload) ==
               {:error, :cannot_update_first_event_log}
    end

    test "returns an error if give payload is not valid" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          10,
          1,
          payload
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          9,
          1,
          payload
        )

      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      new_payload = %{
        "operation" => nil,
        "team-type" => nil,
        "stat-id" => nil,
        "player-id" => nil
      }

      assert EventLogs.update_payload(event_log2.id, new_payload) ==
               {:error, :invalid_payload}
    end

    test "calls EventLogCache.refresh after successful update_payload" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          10,
          1,
          %{}
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          5,
          1,
          payload
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          "7488a646-e31f-11e4-aace-600308960668",
          2,
          1,
          payload
        )

      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, _event_log2} = EventLogs.persist(event2, game_state)
      {:ok, event_log3} = EventLogs.persist(event3, game_state)

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_last_snapshot_updated,
        fn
          _game_id, _pub_sub ->
            :ok
        end
      )

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_event_logs_updated,
        fn
          _game_id, _recent_events, _pub_sub ->
            :ok
        end
      )

      expect(EventLogCacheMock, :refresh, fn game_id ->
        assert game_id == "7488a646-e31f-11e4-aace-600308960668"
        :ok
      end)

      expect(EventLogCacheMock, :get, fn game_id ->
        assert game_id == "7488a646-e31f-11e4-aace-600308960668"
        {:ok, []}
      end)

      new_payload = %{
        "operation" => "decrement",
        "team-type" => "away",
        "player-id" => "456",
        "stat-id" => "field_goals_made"
      }

      {:ok, updated_event_log} =
        EventLogs.update_payload(
          event_log3.id,
          new_payload,
          GoChampsScoreboard.Games.Messages.PubSubMock,
          EventLogCacheMock
        )

      assert updated_event_log.payload == new_payload
      verify!(EventLogCacheMock)
    end
  end

  describe "update_subsequent_snapshots/1" do
    test "updates the snapshots of all subsequent event logs after a specific event log" do
      game_state = basketball_game_state_fixture()

      payload_increment_field_goals_made = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event1 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          8,
          1,
          payload_increment_field_goals_made
        )

      game_state_for_event1 =
        Handler.handle(game_state, event1)

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload_increment_field_goals_made
        )

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          6,
          1,
          payload_increment_field_goals_made
        )

      event4 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          5,
          1,
          payload_increment_field_goals_made
        )

      # Note we are persisting events with the same game state
      # So the last snapshot does not contains the effects of all events
      {:ok, _event_log1} = EventLogs.persist(event1, game_state_for_event1)
      {:ok, event_log2} = EventLogs.persist(event2, game_state_for_event1)
      {:ok, _event_log3} = EventLogs.persist(event3, game_state_for_event1)
      {:ok, _event_log4} = EventLogs.persist(event4, game_state_for_event1)

      {[{:ok, updated_event_log2}, {:ok, updated_event_log3}, {:ok, updated_event_log4}], _} =
        EventLogs.update_subsequent_snapshots(event_log2)

      exppected_game_state_for_event2 =
        Handler.handle(game_state_for_event1, event2)

      exppected_game_state_for_event3 =
        Handler.handle(exppected_game_state_for_event2, event3)

      exppected_game_state_for_event4 =
        Handler.handle(exppected_game_state_for_event3, event4)

      assert updated_event_log2.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               exppected_game_state_for_event2
               |> get_field_goals_made_from_player_in_game_state("123")

      assert updated_event_log3.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               exppected_game_state_for_event3
               |> get_field_goals_made_from_player_in_game_state("123")

      assert updated_event_log4.snapshot.state
             |> get_field_goals_made_from_player_in_game_state("123") ==
               exppected_game_state_for_event4
               |> get_field_goals_made_from_player_in_game_state("123")
    end

    test "returns an error if the event log is the first event log" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload
        )

      {:ok, event_log} = EventLogs.persist(event, game_state)

      assert EventLogs.update_subsequent_snapshots(event_log) == {:error, :first_event_log}
    end

    test "handles player addition and subsequent stats correctly after update_subsequent_snapshots" do
      game_state = basketball_game_state_fixture()

      event_a =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      game_state_after_a = Handler.handle(game_state, event_a)
      {:ok, _event_log_a} = EventLogs.persist(event_a, game_state_after_a)

      # EventB: UpdatePlayerStatDefinition of existing player
      # Player exists in basketball_game_state_fixture
      existing_player_id = "123"

      event_b =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          590,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => existing_player_id,
            "stat-id" => "field_goals_made"
          }
        )

      game_state_after_b = Handler.handle(game_state_after_a, event_b)
      {:ok, event_log_b} = EventLogs.persist(event_b, game_state_after_b)

      event_c =
        GoChampsScoreboard.Events.Definitions.AddPlayerToTeamDefinition.create(
          game_state.id,
          580,
          1,
          %{
            "team-type" => "home",
            "name" => "New Player",
            "number" => 99
          }
        )

      game_state_after_c = Handler.handle(game_state_after_b, event_c)
      {:ok, _event_log_c} = EventLogs.persist(event_c, game_state_after_c)

      new_player =
        game_state_after_c.home_team.players
        |> Enum.find(fn player -> player.name == "New Player" && player.number == 99 end)

      assert new_player != nil
      new_player_id = new_player.id

      event_d =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          570,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => new_player_id,
            "stat-id" => "field_goals_made"
          }
        )

      game_state_after_d = Handler.handle(game_state_after_c, event_d)
      {:ok, _event_log_d} = EventLogs.persist(event_d, game_state_after_d)

      {updated_events, final_game_state} = EventLogs.update_subsequent_snapshots(event_log_b)

      assert length(updated_events) == 3
      assert match?([{:ok, _}, {:ok, _}, {:ok, _}], updated_events)

      [{:ok, _updated_event_log_b}, {:ok, updated_event_log_c}, {:ok, updated_event_log_d}] =
        updated_events

      # Assert that the returned game_state contains the EventD result correctly assigned to the added player
      # The new player should exist in the final game state
      final_new_player =
        final_game_state.home_team.players
        |> Enum.find(fn player -> player.id == new_player_id end)

      assert final_new_player != nil
      assert final_new_player.name == "New Player"
      assert final_new_player.number == 99

      # The new player should have the stats from EventD
      assert final_new_player.stats_values["field_goals_made"] == 1

      # The existing player should still have their updated stats from EventB
      existing_player =
        final_game_state.home_team.players
        |> Enum.find(fn player -> player.id == existing_player_id end)

      assert existing_player != nil
      assert existing_player.stats_values["field_goals_made"] == 1

      # Updated EventC snapshot should have both players but new player with no stats yet
      event_c_state = updated_event_log_c.snapshot.state

      existing_player_in_c =
        event_c_state.home_team.players
        |> Enum.find(fn player -> player.id == existing_player_id end)

      new_player_in_c =
        event_c_state.home_team.players
        |> Enum.find(fn player -> player.id == new_player_id end)

      assert existing_player_in_c.stats_values["field_goals_made"] == 1
      assert new_player_in_c != nil
      assert new_player_in_c.name == "New Player"
      assert new_player_in_c.number == 99
      assert Map.get(new_player_in_c.stats_values, "field_goals_made", 0) == 0

      # Updated EventD snapshot should have both players with their respective stats
      event_d_state = updated_event_log_d.snapshot.state

      existing_player_in_d =
        event_d_state.home_team.players
        |> Enum.find(fn player -> player.id == existing_player_id end)

      new_player_in_d =
        event_d_state.home_team.players
        |> Enum.find(fn player -> player.id == new_player_id end)

      assert existing_player_in_d.stats_values["field_goals_made"] == 1
      assert new_player_in_d.stats_values["field_goals_made"] == 1

      # Verify final game state matches EventD snapshot
      assert final_game_state == event_d_state
    end

    test "handles coach addition and subsequent stats correctly after update_subsequent_snapshots" do
      game_state = basketball_game_state_fixture()

      event_a =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          600,
          1,
          %{}
        )

      game_state_after_a = Handler.handle(game_state, event_a)
      {:ok, _event_log_a} = EventLogs.persist(event_a, game_state_after_a)

      existing_coach_id = "coach-id"

      event_b =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          590,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => existing_coach_id,
            "stat-id" => "fouls_technical"
          }
        )

      game_state_after_b = Handler.handle(game_state_after_a, event_b)
      {:ok, event_log_b} = EventLogs.persist(event_b, game_state_after_b)

      event_c =
        GoChampsScoreboard.Events.Definitions.AddCoachToTeamDefinition.create(
          game_state.id,
          580,
          1,
          %{
            "team-type" => "home",
            "name" => "New Coach",
            "type" => "assistant_coach"
          }
        )

      game_state_after_c = Handler.handle(game_state_after_b, event_c)
      {:ok, _event_log_c} = EventLogs.persist(event_c, game_state_after_c)

      new_coach =
        game_state_after_c.home_team.coaches
        |> Enum.find(fn coach -> coach.name == "New Coach" && coach.type == "assistant_coach" end)

      assert new_coach != nil
      new_coach_id = new_coach.id

      event_d =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          570,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => new_coach_id,
            "stat-id" => "fouls_technical"
          }
        )

      game_state_after_d = Handler.handle(game_state_after_c, event_d)
      {:ok, _event_log_d} = EventLogs.persist(event_d, game_state_after_d)

      {updated_events, final_game_state} = EventLogs.update_subsequent_snapshots(event_log_b)

      assert length(updated_events) == 3
      assert match?([{:ok, _}, {:ok, _}, {:ok, _}], updated_events)

      [{:ok, _updated_event_log_b}, {:ok, _updated_event_log_c}, {:ok, _updated_event_log_d}] =
        updated_events

      # Assert that the returned game_state contains the EventD result correctly assigned to the added coach
      # The new coach should exist in the final game state
      final_new_coach =
        final_game_state.home_team.coaches
        |> Enum.find(fn coach -> coach.id == new_coach_id end)

      assert final_new_coach != nil
      assert final_new_coach.name == "New Coach"
      assert final_new_coach.type == :assistant_coach

      # The new coach should have the stats from EventD
      assert final_new_coach.stats_values["fouls_technical"] == 1

      existing_coach =
        final_game_state.home_team.coaches
        |> Enum.find(fn coach -> coach.id == existing_coach_id end)

      assert existing_coach != nil
      assert existing_coach.stats_values["fouls_technical"] == 1
    end
  end

  describe "apply_to_game_state/2" do
    test "applies an event log to a game state" do
      game_state = basketball_game_state_fixture()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload
        )

      {:ok, event_log} = EventLogs.persist(event, game_state)

      updated_game_state = EventLogs.apply_to_game_state(event_log, game_state)

      updated_player_field_goals_made =
        updated_game_state.home_team.players
        |> find_player_by_id("123")
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      original_player_field_goals_made =
        game_state.home_team.players
        |> find_player_by_id("123")
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      assert updated_player_field_goals_made == original_player_field_goals_made + 1

      assert updated_game_state.home_team.total_player_stats["field_goals_made"] ==
               game_state.home_team.total_player_stats["field_goals_made"] + 1
    end

    test "calls PubSub.broadcast_game_last_snapshot_updated when payload is successfully updated" do
      game_state = basketball_game_state_fixture()

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_last_snapshot_updated,
        fn game_id, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      expect(
        GoChampsScoreboard.Games.Messages.PubSubMock,
        :broadcast_game_event_logs_updated,
        fn game_id, _recent_events, _pub_sub ->
          assert game_id == game_state.id
          :ok
        end
      )

      first_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          10,
          1,
          %{}
        )

      # Use a player ID that exists in the basketball fixture
      home_player = List.first(game_state.home_team.players)

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => home_player.id,
        "stat-id" => "field_goals_made"
      }

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          20,
          1,
          payload
        )

      {:ok, _first_event_log} = EventLogs.persist(first_event, game_state)

      updated_game_state = Handler.handle(game_state, event)
      {:ok, second_event_log} = EventLogs.persist(event, updated_game_state)

      # Create a third event
      second_event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          30,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => home_player.id,
            "stat-id" => "free_throws_made"
          }
        )

      updated_game_state2 = Handler.handle(updated_game_state, second_event)
      {:ok, _third_event_log} = EventLogs.persist(second_event, updated_game_state2)

      new_payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => home_player.id,
        "stat-id" => "rebounds_defensive"
      }

      # Test that update_payload calls PubSub correctly (update the second event, not the first)
      result =
        EventLogs.update_payload(
          second_event_log.id,
          new_payload,
          GoChampsScoreboard.Games.Messages.PubSubMock
        )

      assert {:ok, _updated_event_log} = result
      verify!()
    end
  end

  defp find_player_by_id(players, player_id) do
    Enum.find(players, fn player -> player.id == player_id end)
  end

  defp get_field_goals_made_from_player_in_game_state(game_state, player_id, team \\ "home") do
    case team do
      "home" ->
        game_state.home_team.players
        |> find_player_by_id(player_id)
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      "away" ->
        game_state.away_team.players
        |> find_player_by_id(player_id)
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")
    end
  end

  defp get_rebounds_defensive_from_player_in_game_state(game_state, player_id, team \\ "home") do
    case team do
      "home" ->
        game_state.home_team.players
        |> find_player_by_id(player_id)
        |> Map.get(:stats_values)
        |> Map.get("rebounds_defensive")

      "away" ->
        game_state.away_team.players
        |> find_player_by_id(player_id)
        |> Map.get(:stats_values)
        |> Map.get("rebounds_defensive")
    end
  end
end
