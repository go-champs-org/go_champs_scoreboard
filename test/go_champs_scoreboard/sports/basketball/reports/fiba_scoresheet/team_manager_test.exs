defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManagerTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  describe "bootstrap/1" do
    test "returns a FibaScoresheet.Team struct with initial values for 2PT" do
      team_state = %{
        name: "Some team",
        players: [
          %{id: "123", name: "Player 1", number: 12},
          %{id: "456", name: "Player 2", number: 23}
        ]
      }

      expected = %FibaScoresheet.Team{
        name: "Some team",
        players: [
          %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []},
          %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
        ],
        coach: %FibaScoresheet.Coach{
          id: "coach-id",
          name: "First coach",
          fouls: []
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "ass-coach",
          name: "Ass Coach",
          fouls: []
        },
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      assert expected == TeamManager.bootstrap(team_state)
    end
  end

  describe "add_score/2" do
    test "updates the running score for a team" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      point_score = %FibaScoresheet.PointScore{
        player_number: 20,
        type: "2PT",
        is_last_of_period: false
      }

      updated_team = TeamManager.add_score(team, point_score)

      expected_running_score = %{2 => point_score}
      assert updated_team.running_score == expected_running_score
      assert updated_team.score == 2
    end

    test "updates the running score with the sum of current score and point score for 3PT" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{
          2 => %FibaScoresheet.PointScore{
            player_number: 20,
            type: "2PT",
            is_last_of_period: false
          }
        },
        score: 2
      }

      point_score = %FibaScoresheet.PointScore{
        player_number: 20,
        type: "3PT",
        is_last_of_period: false
      }

      updated_team = TeamManager.add_score(team, point_score)

      expected_running_score = Map.put(team.running_score, 5, point_score)
      assert updated_team.running_score == expected_running_score
      assert updated_team.score == 5
    end

    test "updates the running score with the sum of current score and point score for FT" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{
          2 => %FibaScoresheet.PointScore{
            player_number: 20,
            type: "2PT",
            is_last_of_period: false
          }
        },
        score: 2
      }

      point_score = %FibaScoresheet.PointScore{
        player_number: 20,
        type: "FT",
        is_last_of_period: false
      }

      updated_team = TeamManager.add_score(team, point_score)

      expected_running_score = Map.put(team.running_score, 3, point_score)
      assert updated_team.running_score == expected_running_score
      assert updated_team.score == 3
    end
  end

  describe "add_player_foul/3" do
    test "adds a foul to the player's list" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [%FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      foul = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil
      }

      updated_team = TeamManager.add_player_foul(team, "123", foul)
      player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      assert player.fouls == [foul]
      assert updated_team.all_fouls == [foul]
    end
  end
end
