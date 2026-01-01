defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.RegisterTeamWoProcessorTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.RegisterTeamWoProcessor

  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns fiba scoresheet data for walkover team when team-type is home" do
      event_log = %EventLog{
        key: "register-team-wo",
        payload: %{"team-type" => "home"},
        snapshot: %{
          state: %{
            home_team: %{
              players: []
            },
            away_team: %{
              players: [%{id: "player3", state: :playing}, %{id: "player4", state: :bench}]
            }
          }
        }
      }

      mock_team_a_players = [
        %FibaScoresheet.Player{id: "player1", name: "Player One", has_started: false},
        %FibaScoresheet.Player{id: "player2", name: "Player Two", has_started: false}
      ]

      mock_team_b_players = [
        %FibaScoresheet.Player{id: "player3", name: "Player Three", has_started: false},
        %FibaScoresheet.Player{id: "player4", name: "Player Four", has_started: false}
      ]

      initial_data =
        fiba_scoresheet_fixture(
          team_a_players: mock_team_a_players,
          team_b_players: mock_team_b_players
        )

      result = RegisterTeamWoProcessor.process(event_log, initial_data)
      assert result.team_a.players == []
      assert result.team_a.coach == %FibaScoresheet.Coach{id: "", name: "", fouls: []}
      assert result.team_a.assistant_coach == %FibaScoresheet.Coach{id: "", name: "", fouls: []}
      assert result.team_a.has_walkover == true
      assert result.team_a.score == 0
      assert result.team_b.players |> Enum.at(0) |> Map.get(:has_started) == true
      assert result.team_b.players |> Enum.at(1) |> Map.get(:has_started) == false
      assert result.team_b.coach != nil
      assert result.team_b.assistant_coach != nil
      assert result.team_b.has_walkover == false
      assert result.team_b.score == 20
    end

    test "returns fiba scoresheet data for walkover team when team-type is away" do
      event_log = %EventLog{
        key: "register-team-wo",
        payload: %{"team-type" => "away"},
        snapshot: %{
          state: %{
            home_team: %{
              players: [%{id: "player1", state: :playing}, %{id: "player2", state: :bench}]
            },
            away_team: %{
              players: []
            }
          }
        }
      }

      mock_team_a_players = [
        %FibaScoresheet.Player{id: "player1", name: "Player One", has_started: false},
        %FibaScoresheet.Player{id: "player2", name: "Player Two", has_started: false}
      ]

      mock_team_b_players = [
        %FibaScoresheet.Player{id: "player3", name: "Player Three", has_started: false},
        %FibaScoresheet.Player{id: "player4", name: "Player Four", has_started: false}
      ]

      initial_data =
        fiba_scoresheet_fixture(
          team_a_players: mock_team_a_players,
          team_b_players: mock_team_b_players
        )

      result = RegisterTeamWoProcessor.process(event_log, initial_data)
      assert result.team_b.players == []
      assert result.team_b.coach == %FibaScoresheet.Coach{id: "", name: "", fouls: []}
      assert result.team_b.assistant_coach == %FibaScoresheet.Coach{id: "", name: "", fouls: []}
      assert result.team_b.has_walkover == true
      assert result.team_b.score == 0
      assert result.team_a.players |> Enum.at(0) |> Map.get(:has_started) == true
      assert result.team_a.players |> Enum.at(1) |> Map.get(:has_started) == false
      assert result.team_a.coach != nil
      assert result.team_a.assistant_coach != nil
      assert result.team_a.has_walkover == false
      assert result.team_a.score == 20
    end
  end
end
