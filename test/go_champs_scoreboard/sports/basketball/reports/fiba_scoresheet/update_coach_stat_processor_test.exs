defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_technical operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "C",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_disqualifying operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "D",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_technical_bench operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "coach-id" => "away-coach-id",
            "stat-id" => "fouls_technical_bench"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_coach =
        %FibaScoresheet.Coach{
          id: "away-coach-id",
          name: "Coach 2",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_coach: team_b_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "B",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_b.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_b.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_game_disqualifying operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_game_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "GD",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == expected_fouls
    end
  end
end
