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
                 minute: 0
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
                 minute: 3
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
                 minute: 8
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
                 minute: 5
               }
             ]
    end
  end
end
