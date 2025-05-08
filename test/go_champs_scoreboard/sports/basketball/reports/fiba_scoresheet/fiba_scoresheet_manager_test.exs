defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManagerTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  import GoChampsScoreboard.GameStateFixtures

  describe "bootstrap/1" do
    test "returns a FibaScoresheet struct with game_id" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{}
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      expected = %FibaScoresheet{
        game_id: event_log.game_id,
        tournament_name: "",
        header: %FibaScoresheet.Header{},
        team_a: %FibaScoresheet.Team{
          name: "Some home team",
          coaches: [],
          players: [%FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}],
          all_fouls: [],
          running_score: %{},
          score: 0
        },
        team_b: %FibaScoresheet.Team{
          name: "Some away team",
          coaches: [],
          players: [%FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}],
          all_fouls: [],
          running_score: %{},
          score: 0
        }
      }

      assert expected == FibaScoresheetManager.bootstrap(event_log)
    end
  end

  describe "find_team/2" do
    test "returns the team with a given type" do
      team_a = %FibaScoresheet.Team{name: "Team A", players: []}
      team_b = %FibaScoresheet.Team{name: "Team B", players: []}

      fiba_scoresheet = %FibaScoresheet{
        team_a: team_a,
        team_b: team_b
      }

      assert FibaScoresheetManager.find_team(fiba_scoresheet, "home") == team_a
      assert FibaScoresheetManager.find_team(fiba_scoresheet, "away") == team_b
    end
  end

  describe "update_team/3" do
    test "updates the team with the given type" do
      team_a = %FibaScoresheet.Team{name: "Team A", players: []}
      team_b = %FibaScoresheet.Team{name: "Team B", players: []}

      fiba_scoresheet = %FibaScoresheet{
        team_a: team_a,
        team_b: team_b
      }

      updated_team = %FibaScoresheet.Team{name: "Updated Team A", players: []}

      updated_fiba_scoresheet =
        FibaScoresheetManager.update_team(fiba_scoresheet, "home", updated_team)

      assert updated_fiba_scoresheet.team_a.name == "Updated Team A"
      assert updated_fiba_scoresheet.team_b.name == "Team B"
    end
  end
end
