defmodule GoChampsScoreboard.Games.EventLogsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias Ecto.Repo
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.GameSnapshot
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures

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
  end

  describe "get_first_created_by_game_id/1" do
    test "retrieves the first event log with game snapshot for a specific game ID" do
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      game_state = game_state_fixture()

      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_id,
          1,
          1,
          %{}
        )

      update_player_stat_event =
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

      {:ok, first_event_log} = EventLogs.persist(start_live_event, game_state)
      {:ok, _second_event_log} = EventLogs.persist(update_player_stat_event, game_state)
      {:ok, _third_event_log} = EventLogs.persist(update_player_stat_event, game_state)

      retrieved_event_log = EventLogs.get_first_created_by_game_id(game_id)

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
      game_id = "7488a646-e31f-11e4-aace-600308960668"

      game_state = game_state_fixture()

      start_live_event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_id,
          1,
          1,
          %{}
        )

      update_player_stat_event =
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

      {:ok, _second_event_log} = EventLogs.persist(update_player_stat_event, game_state)
      {:ok, first_event_log} = EventLogs.persist(start_live_event, game_state)

      retrieved_event_log = EventLogs.get_first_created_by_game_id(game_id)

      assert retrieved_event_log.id == first_event_log.id
    end

    test "returns nil for non-existent game ID" do
      assert EventLogs.get_first_created_by_game_id(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_pior/1" do
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

      retrieved_event_log = EventLogs.get_pior(event_log2)

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
      retrieved_event_log = EventLogs.get_pior(event_log)
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
  end

  describe "update_single_snapshot/2" do
    test "updates the event log snapshot applying its payload to prior event log snapshot" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
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
          payload1
        )

      event2 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          7,
          1,
          payload2
        )

      game_state_for_event1 =
        Handler.handle(game_state, event1)

      expected_game_state_for_event2 =
        Handler.handle(game_state_for_event1, event2)

      expected_player_field_goals_made =
        expected_game_state_for_event2.home_team.players
        |> find_player_by_id("123")
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      {:ok, event_log1} = EventLogs.persist(event1, game_state_for_event1)
      # Persist the second event log with the first event log's snapshot
      {:ok, event_log2} = EventLogs.persist(event2, game_state_for_event1)

      {:ok, _updated_snapshot} = EventLogs.update_single_snapshot(event_log2, event_log1)

      updated_event_log2_with_snapshot =
        EventLogs.get(event_log2.id, with_snapshot: true)

      actual_player_field_goals_made =
        updated_event_log2_with_snapshot.snapshot.state.home_team.players
        |> find_player_by_id("123")
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      assert actual_player_field_goals_made ==
               expected_player_field_goals_made
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
  end

  describe "reduce_event_logs_to_game_state/2" do
    test "reduces event logs to a game state" do
      game_state = basketball_game_state_fixture()

      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => "field_goals_made"
      }

      payload2 = %{
        "operation" => "increment",
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

      event3 =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          payload3
        )

      {:ok, event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)
      {:ok, event_log3} = EventLogs.persist(event3, game_state)

      event_logs = [event_log1, event_log2, event_log3]

      final_game_state = EventLogs.reduce_event_logs_to_game_state(event_logs, game_state)

      updated_player_field_goals_made =
        final_game_state.home_team.players
        |> find_player_by_id("123")
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      original_player_field_goals_made =
        game_state.home_team.players
        |> find_player_by_id("123")
        |> Map.get(:stats_values)
        |> Map.get("field_goals_made")

      # There are two increments of field_goals_made
      assert updated_player_field_goals_made == original_player_field_goals_made + 2

      updated_player_rebounds =
        final_game_state.away_team.players
        |> find_player_by_id("456")
        |> Map.get(:stats_values)
        |> Map.get("rebounds_defensive")

      original_player_rebounds =
        game_state.away_team.players
        |> find_player_by_id("456")
        |> Map.get(:stats_values)
        |> Map.get("rebounds_defensive")

      assert updated_player_rebounds == original_player_rebounds + 1
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
