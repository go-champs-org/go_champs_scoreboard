defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns a fiba scoresheet data running score when event log payload with free_throws_made operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "free_throws_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_running_score = %{
        1 => %FibaScoresheet.PointScore{
          type: "FT",
          player_number: 12,
          is_last_of_quarter: false
        }
      }

      assert result_scoresheet.team_a.running_score == expected_running_score
      assert result_scoresheet.team_a.score == 1
    end

    test "returns a fiba scoresheet data running score when event log payload with field_goals_made operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "field_goals_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_running_score = %{
        2 => %FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 23,
          is_last_of_quarter: false
        }
      }

      assert result_scoresheet.team_b.running_score == expected_running_score
      assert result_scoresheet.team_b.score == 2
    end

    test "returns a fiba scoresheet data running score when event log payload with three_point_field_goals_made operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "three_point_field_goals_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_running_score = %{
        3 => %FibaScoresheet.PointScore{
          type: "3PT",
          player_number: 23,
          is_last_of_quarter: false
        }
      }

      assert result_scoresheet.team_b.running_score == expected_running_score
      assert result_scoresheet.team_b.score == 3
    end
  end
end
