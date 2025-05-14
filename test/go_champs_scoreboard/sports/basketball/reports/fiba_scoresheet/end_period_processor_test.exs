defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EndPeriodProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EndPeriodProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns a fiba scoresheet data with current point score marked as last of period" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.EndPeriodDefinition.create(
          game_state.id,
          0,
          1,
          %{}
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(
          game_id: event_log.game_id,
          team_a_players: team_a_players,
          team_b_players: team_b_players
        )

      # 10 points in total
      updated_team_a =
        fiba_scoresheet
        |> FibaScoresheetManager.find_team("home")
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 12,
          period: 1,
          is_last_of_period: false
        })
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 12,
          period: 1,
          is_last_of_period: false
        })
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 12,
          period: 1,
          is_last_of_period: false
        })
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 12,
          period: 1,
          is_last_of_period: false
        })
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 12,
          period: 1,
          is_last_of_period: false
        })

      # 6 Points in total
      updated_team_b =
        fiba_scoresheet
        |> FibaScoresheetManager.find_team("away")
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 23,
          period: 1,
          is_last_of_period: false
        })
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 23,
          period: 1,
          is_last_of_period: false
        })
        |> TeamManager.add_score(%FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 23,
          period: 1,
          is_last_of_period: false
        })

      fiba_scoresheet =
        fiba_scoresheet
        |> FibaScoresheetManager.update_team("home", updated_team_a)
        |> FibaScoresheetManager.update_team("away", updated_team_b)

      result_scoresheet =
        EndPeriodProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet
             |> FibaScoresheetManager.find_team("home")
             |> Map.get(:running_score)
             |> Map.get(10) == %FibaScoresheet.PointScore{
               type: "2PT",
               player_number: 12,
               period: 1,
               is_last_of_period: true
             }

      assert result_scoresheet
             |> FibaScoresheetManager.find_team("away")
             |> Map.get(:running_score)
             |> Map.get(6) == %FibaScoresheet.PointScore{
               type: "2PT",
               player_number: 23,
               period: 1,
               is_last_of_period: true
             }
    end
  end
end
