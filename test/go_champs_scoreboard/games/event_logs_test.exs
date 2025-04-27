defmodule GoChampsScoreboard.Games.EventLogsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias GoChampsScoreboard.Games.Models.GameState
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

    test "returns nil for non-existent game ID" do
      assert EventLogs.get_first_created_by_game_id(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_pior_event_log/1" do
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

      retrieved_event_log = EventLogs.get_pior_event_log(event_log2)

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
      retrieved_event_log = EventLogs.get_pior_event_log(event_log)
      # Since this is the first event log, it should return nil
      assert retrieved_event_log == nil
    end
  end

  describe "get_subsequent_event_logs/1" do
    test "retrieves all event logs after a specific event log" do
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

      retrieved_event_logs = EventLogs.get_subsequent_event_logs(event_log1)

      assert length(retrieved_event_logs) == 1
      assert Enum.at(retrieved_event_logs, 0).id == event_log2.id
      assert Enum.at(retrieved_event_logs, 0).key == event_log2.key
      assert Enum.at(retrieved_event_logs, 0).game_id == event_log2.game_id
      assert Enum.at(retrieved_event_logs, 0).payload == event_log2.payload
    end

    test "retrievs all event logs until the last event log after s specific event log" do
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

      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)
      {:ok, event_log3} = EventLogs.persist(event3, game_state)
      {:ok, event_log4} = EventLogs.persist(event4, game_state)

      retrieved_event_logs = EventLogs.get_subsequent_event_logs(event_log2)

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

      {:ok, _event_log1} = EventLogs.persist(event1, game_state)
      {:ok, event_log2} = EventLogs.persist(event2, game_state)

      # Attempt to retrie ve event logs after the last event log
      retrieved_event_logs = EventLogs.get_subsequent_event_logs(event_log2)

      assert retrieved_event_logs == []
    end
  end

  describe "apply_event_log_to_game_state/2" do
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

      updated_game_state = EventLogs.apply_event_log_to_game_state(event_log, game_state)

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

      assert updated_player_rebounds == original_player_rebounds - 1
    end
  end

  defp find_player_by_id(players, player_id) do
    Enum.find(players, fn player -> player.id == player_id end)
  end
end
