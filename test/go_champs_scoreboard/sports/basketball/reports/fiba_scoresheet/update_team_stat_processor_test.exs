defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateTeamStatProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateTeamStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns a fiba scoresheet with home team timeout when event log payload with team-type is home and stat-id is timeouts" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          600,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_a.timeouts == [
               %FibaScoresheet.Timeout{
                 period: game_state.clock_state.period,
                 minute: 0,
                 lost: false
               }
             ]
    end

    test "returns a fiba scoresheet with away team timeout when event log payload with team-type is away and stat-id is timeouts" do
      game_state = basketball_game_state_fixture()

      # Simulate a game clock time of 7 minutes and 15 seconds
      time_in_seconds = 435

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          time_in_seconds,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "stat-id" => "timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_b.timeouts == [
               %FibaScoresheet.Timeout{
                 period: game_state.clock_state.period,
                 minute: 3,
                 lost: false
               }
             ]
    end

    test "returns a fiba scoresheet with home team timeout when event log payload with team-type is home and stat-id is timeouts and period is 4" do
      game_state = basketball_game_state_fixture()

      # Simulate a game clock time of 2 minutes and 17 seconds
      time_in_seconds = 137

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          time_in_seconds,
          4,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_a.timeouts == [
               %FibaScoresheet.Timeout{
                 period: 4,
                 minute: 8,
                 lost: false
               }
             ]
    end

    test "returns a fiba scoresheet with away team timeout when event log payload with team-type is away and stat-id is timeouts and period is 5" do
      game_state = basketball_game_state_fixture()

      # Simulate a game clock time of 43 seconds
      time_in_seconds = 43

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          time_in_seconds,
          5,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "stat-id" => "timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_b.timeouts == [
               %FibaScoresheet.Timeout{
                 period: 5,
                 minute: 5,
                 lost: false
               }
             ]
    end
  end

  describe "process/2 with lost_timeouts" do
    test "returns a fiba scoresheet with home team lost timeout when event log payload with team-type is home and stat-id is lost_timeouts" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          600,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "lost_timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_a.timeouts == [
               %FibaScoresheet.Timeout{
                 period: game_state.clock_state.period,
                 minute: 0,
                 lost: true
               }
             ]
    end

    test "returns a fiba scoresheet with away team lost timeout when event log payload with team-type is away and stat-id is lost_timeouts" do
      game_state = basketball_game_state_fixture()

      # Simulate a game clock time of 7 minutes and 15 seconds
      time_in_seconds = 435

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          time_in_seconds,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "stat-id" => "lost_timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_b.timeouts == [
               %FibaScoresheet.Timeout{
                 period: game_state.clock_state.period,
                 minute: 3,
                 lost: true
               }
             ]
    end

    test "returns a fiba scoresheet with home team lost timeout when event log payload with team-type is home and stat-id is lost_timeouts and period is 4" do
      game_state = basketball_game_state_fixture()

      # Simulate a game clock time of 2 minutes and 17 seconds
      time_in_seconds = 137

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          time_in_seconds,
          4,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "lost_timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_a.timeouts == [
               %FibaScoresheet.Timeout{
                 period: 4,
                 minute: 8,
                 lost: true
               }
             ]
    end

    test "returns a fiba scoresheet with away team lost timeout when event log payload with team-type is away and stat-id is lost_timeouts and period is 5" do
      game_state = basketball_game_state_fixture()

      # Simulate a game clock time of 43 seconds
      time_in_seconds = 43

      event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          time_in_seconds,
          5,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "stat-id" => "lost_timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id)

      result_scoresheet =
        UpdateTeamStatProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_b.timeouts == [
               %FibaScoresheet.Timeout{
                 period: 5,
                 minute: 5,
                 lost: true
               }
             ]
    end

    test "correctly handles both regular and lost timeouts for the same team" do
      game_state = basketball_game_state_fixture()

      # Add a regular timeout first
      timeout_event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          game_state.id,
          600,
          1,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "timeouts"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, timeout_event)

      {:ok, timeout_event_log} = EventLogs.persist(timeout_event, updated_game_state)

      # Add a lost timeout
      lost_timeout_event =
        GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition.create(
          updated_game_state.id,
          300,
          2,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "stat-id" => "lost_timeouts"
          }
        )

      final_game_state =
        GoChampsScoreboard.Events.Handler.handle(updated_game_state, lost_timeout_event)

      {:ok, lost_timeout_event_log} = EventLogs.persist(lost_timeout_event, final_game_state)

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: timeout_event_log.game_id)

      # Process both events
      result_scoresheet =
        fiba_scoresheet
        |> (&UpdateTeamStatProcessor.process(timeout_event_log, &1)).()
        |> (&UpdateTeamStatProcessor.process(lost_timeout_event_log, &1)).()

      assert length(result_scoresheet.team_a.timeouts) == 2

      # Check regular timeout
      regular_timeout = Enum.find(result_scoresheet.team_a.timeouts, &(&1.lost == false))
      assert regular_timeout.period == 1
      assert regular_timeout.minute == 0
      assert regular_timeout.lost == false

      # Check lost timeout
      lost_timeout = Enum.find(result_scoresheet.team_a.timeouts, &(&1.lost == true))
      assert lost_timeout.period == 2
      assert lost_timeout.minute == 5
      assert lost_timeout.lost == true
    end
  end
end
