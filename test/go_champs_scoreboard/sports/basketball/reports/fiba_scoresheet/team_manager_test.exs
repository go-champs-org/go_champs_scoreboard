defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManagerTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  describe "bootstrap/1" do
    test "returns a FibaScoresheet.Team struct with initial values for 2PT" do
      team_state = %{
        name: "Some team",
        players: [
          %{id: "123", name: "Player 1", number: 12, state: :available},
          %{id: "456", name: "Player 2", number: 23, state: :available, license_number: "CD34"}
        ]
      }

      expected = %FibaScoresheet.Team{
        name: "Some team",
        players: [
          %FibaScoresheet.Player{
            id: "123",
            name: "Player 1",
            number: 12,
            fouls: [],
            license_number: ""
          },
          %FibaScoresheet.Player{
            id: "456",
            name: "Player 2",
            number: 23,
            fouls: [],
            license_number: "CD34"
          }
        ],
        coach: %FibaScoresheet.Coach{
          id: "",
          name: "",
          fouls: []
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "",
          name: "",
          fouls: []
        },
        all_fouls: [],
        timeouts: [],
        running_score: %{},
        score: 0
      }

      assert expected == TeamManager.bootstrap(team_state)
    end

    test "returns a FibaScoresheet.Team struct ignoring not_available players" do
      team_state = %{
        name: "Some team",
        players: [
          %{id: "123", name: "Player 1", number: 12, state: :available, license_number: "AB12"},
          %{id: "456", name: "Player 2", number: 23, state: :not_available}
        ]
      }

      expected = %FibaScoresheet.Team{
        name: "Some team",
        players: [
          %FibaScoresheet.Player{
            id: "123",
            name: "Player 1",
            number: 12,
            fouls: [],
            license_number: "AB12"
          }
        ],
        coach: %FibaScoresheet.Coach{
          id: "",
          name: "",
          fouls: []
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "",
          name: "",
          fouls: []
        },
        all_fouls: [],
        timeouts: [],
        running_score: %{},
        score: 0
      }

      assert expected == TeamManager.bootstrap(team_state)
    end

    test "returns a FibaScoresheet.Team struct with coaches" do
      team_state = %{
        name: "Some team",
        players: [],
        coaches: [
          %CoachState{
            id: "coach-id",
            name: "Eric Spoltra",
            type: :head_coach
          },
          %CoachState{
            id: "assistant-coach-id",
            name: "Pat Riley",
            type: :assistant_coach
          }
        ]
      }

      expected = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Eric Spoltra",
          fouls: []
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "assistant-coach-id",
          name: "Pat Riley",
          fouls: []
        },
        all_fouls: [],
        timeouts: [],
        running_score: %{},
        score: 0
      }

      assert expected == TeamManager.bootstrap(team_state)
    end

    test "returns a FibaScoresheet.Team struct with empty coaches when no coaches are provided" do
      team_state = %{
        name: "Some team",
        players: [],
        coaches: nil
      }

      expected = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{
          id: "",
          name: "",
          fouls: []
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "",
          name: "",
          fouls: []
        },
        all_fouls: [],
        timeouts: [],
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

    test "adds multiple fouls to the end of the player's and team's foul lists" do
      existing_foul = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [
          %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: [existing_foul]}
        ],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [existing_foul],
        running_score: %{},
        score: 0
      }

      new_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: "FT"
      }

      updated_team = TeamManager.add_player_foul(team, "123", new_foul)
      player = Enum.find(updated_team.players, fn p -> p.id == "123" end)

      assert player.fouls == [existing_foul, new_foul]
      assert List.last(player.fouls) == new_foul

      assert updated_team.all_fouls == [existing_foul, new_foul]
      assert List.last(updated_team.all_fouls) == new_foul
    end
  end

  describe "add_coach_foul/3" do
    test "adds a foul to the coach's list" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{id: "coach-id", name: "Coach 1", fouls: []},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      foul = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil
      }

      updated_team = TeamManager.add_coach_foul(team, "coach-id", foul)
      coach = updated_team.coach
      assert coach.fouls == [foul]
      assert updated_team.all_fouls == [foul]
    end

    test "adds multiple fouls to the end of the coach's and team's foul lists" do
      existing_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{id: "coach-id", name: "Coach 1", fouls: [existing_foul]},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [existing_foul],
        running_score: %{},
        score: 0
      }

      new_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: "FT"
      }

      updated_team = TeamManager.add_coach_foul(team, "coach-id", new_foul)
      coach = updated_team.coach

      # Verify the new foul is added at the end of the coach's fouls array
      assert coach.fouls == [existing_foul, new_foul]
      assert List.last(coach.fouls) == new_foul

      # Verify the new foul is added at the end of the team's all_fouls array
      assert updated_team.all_fouls == [existing_foul, new_foul]
      assert List.last(updated_team.all_fouls) == new_foul
    end
  end

  describe "add_timeout/2" do
    test "adds a timeout to the team's timeouts list" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{},
        score: 0,
        timeouts: []
      }

      timeout = %FibaScoresheet.Timeout{
        period: 1,
        minute: 0
      }

      updated_team = TeamManager.add_timeout(team, timeout)
      assert updated_team.timeouts == [timeout]
    end

    test "adds multiple timeouts to the end of the team's timeouts list" do
      existing_timeout = %FibaScoresheet.Timeout{
        period: 1,
        minute: 5
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{},
        score: 0,
        timeouts: [existing_timeout]
      }

      new_timeout = %FibaScoresheet.Timeout{
        period: 2,
        minute: 8
      }

      updated_team = TeamManager.add_timeout(team, new_timeout)

      # Verify the new timeout is added at the end of the timeouts array
      assert updated_team.timeouts == [existing_timeout, new_timeout]
      assert List.last(updated_team.timeouts) == new_timeout
    end
  end

  describe "update_player/2" do
    test "updates the player in the team" do
      player = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: []
      }

      updated_player = %FibaScoresheet.Player{
        id: "123",
        name: "Updated Player",
        number: 12,
        fouls: []
      }

      team = %FibaScoresheet.Team{
        players: [player]
      }

      result = TeamManager.update_player(updated_player, team)

      assert Enum.any?(result.players, fn p -> p.name == "Updated Player" end)
    end

    test "does not update the team when player id is not found" do
      player = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: []
      }

      updated_player = %FibaScoresheet.Player{
        id: "456",
        name: "Updated Player",
        number: 12,
        fouls: []
      }

      team = %FibaScoresheet.Team{
        players: [player]
      }

      result = TeamManager.update_player(updated_player, team)

      assert Enum.any?(result.players, fn p -> p.name == "Player 1" end)
    end
  end

  describe "mark_score_as_last_of_period/1" do
    test "marks the score as last of period if found" do
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

      updated_team = TeamManager.mark_score_as_last_of_period(team)

      assert updated_team.running_score[2].is_last_of_period == true
    end
  end
end
