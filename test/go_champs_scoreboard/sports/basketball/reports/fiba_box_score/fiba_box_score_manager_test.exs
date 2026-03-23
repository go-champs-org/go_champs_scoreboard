defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.FibaBoxScoreManagerTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.FibaBoxScoreManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.EventProcessor
  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  import GoChampsScoreboard.GameStateFixtures

  describe "bootstrap/1 with full event pipeline" do
    test "returns a FibaBoxScore struct with stats accumulated from events" do
      game_state = basketball_game_state_fixture()

      event_first_quarter =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          1,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "field_goals_made"
          }
        )

      # First quarter away team is home 0 - away 2
      updated_game_state_1 =
        GoChampsScoreboard.Events.Handler.handle(game_state, event_first_quarter)

      event_second_quarter =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          2,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      # Second quarter home team is home 2 - away 2
      updated_game_state_2 =
        GoChampsScoreboard.Events.Handler.handle(
          updated_game_state_1,
          event_second_quarter
        )

      # Third quarter home team is home 4 - away 2
      event_third_quarter =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          3,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      updated_game_state_3 =
        GoChampsScoreboard.Events.Handler.handle(
          updated_game_state_2,
          event_third_quarter
        )

      # Fourth quarter away team is home 4 - away 4
      event_fourth_quarter =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          4,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "field_goals_made"
          }
        )

      updated_game_state_4 =
        GoChampsScoreboard.Events.Handler.handle(
          updated_game_state_3,
          event_fourth_quarter
        )

      # Fifth quarter (overtime) home team is home 6 - away 4
      event_overtime =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          5,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "field_goals_made"
          }
        )

      final_game_state =
        GoChampsScoreboard.Events.Handler.handle(updated_game_state_4, event_overtime)

      # Persist all events with their corresponding post-event game states
      {:ok, _} = EventLogs.persist(event_first_quarter, updated_game_state_1)
      {:ok, _} = EventLogs.persist(event_second_quarter, updated_game_state_2)
      {:ok, _} = EventLogs.persist(event_third_quarter, updated_game_state_3)
      {:ok, _} = EventLogs.persist(event_fourth_quarter, updated_game_state_4)
      {:ok, last_event_log} = EventLogs.persist(event_overtime, final_game_state)

      # Bootstrap from the last event log
      initial_data = FibaBoxScoreManager.bootstrap(last_event_log)

      # Run full event pipeline
      all_events = EventLogs.get_all_by_game_id(game_state.id, with_snapshot: true)

      result =
        Enum.reduce(all_events, initial_data, fn event, acc ->
          EventProcessor.process(event, acc)
        end)
        |> FibaBoxScoreManager.finalize()

      {:ok, expected_datetime, _} = DateTime.from_iso8601("2023-10-01T12:00:00Z")
      {:ok, expected_actual_start_datetime, _} = DateTime.from_iso8601("2023-10-01T13:00:00Z")
      {:ok, expected_actual_end_datetime, _} = DateTime.from_iso8601("2023-10-01T14:00:00Z")

      assert %FibaBoxScore{
               datetime: actual_datetime,
               actual_start_datetime: actual_start_datetime,
               actual_end_datetime: actual_end_datetime
             } = result

      assert actual_datetime == expected_datetime
      assert actual_start_datetime == expected_actual_start_datetime
      assert actual_end_datetime == expected_actual_end_datetime

      # Assert root-level fields
      assert result.number == "ABC123"
      assert result.location == "Game Location"
      assert result.tournament_name == "Tournament Name"
      assert result.tournament_logo_url == "/media/tournament_logo.png"
      assert result.organization_name == "Organization Name"
      assert result.organization_logo_url == "/media/logo.png"
      assert result.web_url == "http://example.com/game_report"
      assert length(result.sponsors) == 2
      assert [sponsor_a, sponsor_b] = result.sponsors
      assert sponsor_a.name == "Sponsor A"
      assert sponsor_a.link == "http://sponsora.com"
      assert sponsor_a.logo_url == "/sponsor_a.png"
      assert sponsor_b.name == "Sponsor B"
      assert sponsor_b.link == "http://sponsorb.com"
      assert sponsor_b.logo_url == "/sponsor_b.png"

      # Assert home_team fields
      home_team = result.home_team
      assert home_team.name == "Some home team"
      assert home_team.points_by_period == %{2 => 2, 3 => 2, 5 => 2}
      assert home_team.total_points == 6
      assert home_team.total_player_stats["field_goals_made"] == 3

      assert [
               %FibaBoxScore.Player{
                 id: "123",
                 name: "Player 1",
                 number: 12,
                 stats_values: player_stats
               },
               %FibaBoxScore.Player{
                 id: "124",
                 name: "Player 2",
                 number: 23,
                 stats_values: _other_player_stats
               }
             ] = home_team.players

      assert player_stats["field_goals_made"] == 3
      assert player_stats["points"] == 6
      assert player_stats["field_goals_attempted"] == 3

      # Assert away_team fields
      away_team = result.away_team
      assert away_team.name == "Some away team"
      assert away_team.points_by_period == %{1 => 2, 4 => 2}
      assert away_team.total_points == 4
      assert away_team.total_player_stats["field_goals_made"] == 2

      assert [
               %FibaBoxScore.Player{
                 id: "456",
                 name: "Player 2",
                 number: 23,
                 stats_values: away_player_stats
               }
             ] = away_team.players

      assert away_player_stats["field_goals_made"] == 2
      assert away_player_stats["points"] == 4
    end
  end
end
