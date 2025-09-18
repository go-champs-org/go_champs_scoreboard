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

    test "handles teams with nil running_score gracefully" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: nil,
        score: 0
      }

      updated_team = TeamManager.mark_score_as_last_of_period(team)

      assert updated_team.running_score == nil
      assert updated_team.score == 0
    end

    test "handles teams with empty running_score map" do
      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [],
        running_score: %{},
        score: 5
      }

      updated_team = TeamManager.mark_score_as_last_of_period(team)

      assert updated_team.running_score == %{}
      assert updated_team.score == 5
    end
  end

  describe "mark_fouls_as_last_of_half/2" do
    test "marks all fouls of players as last of half when given period is 2" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 2)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == true
    end

    test "marks the last foul from earlier periods when player has no fouls in periods 3-4" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 4)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      # Should mark the last foul chronologically (from period 2)
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == true
    end

    test "does not mark fouls when given period is 1" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 1)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == false
    end

    test "does not mark fouls when given period is 3" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 3)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
    end

    test "marks only the last foul as last of half when player has multiple fouls in period 2" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      foul3 = %FibaScoresheet.Foul{
        type: "U",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2, foul3]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2, foul3],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 2)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      # Only the last foul in period 2 should be marked as last of half
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 2).is_last_of_half == true
    end

    test "marks the last foul from period 1 as last of half when player has no fouls in period 2" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 2)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      # The last foul from period 1 should be marked as last of half since period 2 is ending
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == true
    end

    test "marks only the last foul as last of half when player has multiple fouls in period 4" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 4,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 4,
        extra_action: nil,
        is_last_of_half: false
      }

      foul3 = %FibaScoresheet.Foul{
        type: "U",
        period: 4,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2, foul3]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2, foul3],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 4)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      # Only the last foul in period 4 should be marked as last of half
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 2).is_last_of_half == true
    end

    test "marks the last foul from period 3 as last of half when player has no fouls in period 4" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 3,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 3,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 4)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      # The last foul from period 3 should be marked as last of half since period 4 is ending
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == true
    end

    test "prioritizes period 4 fouls over period 3 fouls when both exist" do
      foul1 = %FibaScoresheet.Foul{
        type: "P",
        period: 3,
        extra_action: nil,
        is_last_of_half: false
      }

      foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 4,
        extra_action: nil,
        is_last_of_half: false
      }

      foul3 = %FibaScoresheet.Foul{
        type: "U",
        period: 3,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [foul1, foul2, foul3]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{},
        assistant_coach: %FibaScoresheet.Coach{},
        all_fouls: [foul1, foul2, foul3],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 4)

      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      # Should mark the period 4 foul, not the later period 3 foul
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_player.fouls, 1).is_last_of_half == true
      assert Enum.at(updated_player.fouls, 2).is_last_of_half == false
    end

    test "marks coach fouls as last of half when period 2 ends" do
      coach_foul1 = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      coach_foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      assistant_coach_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: [coach_foul1, coach_foul2]
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "assistant-coach-id",
          name: "Assistant Coach 1",
          fouls: [assistant_coach_foul]
        },
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 2)

      # Coach should have period 2 foul marked
      assert Enum.at(updated_team.coach.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_team.coach.fouls, 1).is_last_of_half == true

      # Assistant coach should have period 1 foul marked (fallback)
      assert Enum.at(updated_team.assistant_coach.fouls, 0).is_last_of_half == true
    end

    test "marks coach fouls as last of half when period 4 ends" do
      coach_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 3,
        extra_action: nil,
        is_last_of_half: false
      }

      assistant_coach_foul1 = %FibaScoresheet.Foul{
        type: "T",
        period: 4,
        extra_action: nil,
        is_last_of_half: false
      }

      assistant_coach_foul2 = %FibaScoresheet.Foul{
        type: "T",
        period: 4,
        extra_action: nil,
        is_last_of_half: false
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [],
        coach: %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: [coach_foul]
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "assistant-coach-id",
          name: "Assistant Coach 1",
          fouls: [assistant_coach_foul1, assistant_coach_foul2]
        },
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 4)

      # Coach should have period 3 foul marked (fallback)
      assert Enum.at(updated_team.coach.fouls, 0).is_last_of_half == true

      # Assistant coach should have last period 4 foul marked
      assert Enum.at(updated_team.assistant_coach.fouls, 0).is_last_of_half == false
      assert Enum.at(updated_team.assistant_coach.fouls, 1).is_last_of_half == true
    end

    test "handles teams with both player and coach fouls correctly" do
      player_foul = %FibaScoresheet.Foul{
        type: "P",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      coach_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [player_foul]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: [coach_foul]
        },
        assistant_coach: %FibaScoresheet.Coach{
          id: "assistant-coach-id",
          name: "Assistant Coach 1",
          fouls: []
        },
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 2)

      # Player should have period 2 foul marked
      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == true

      # Coach should have period 1 foul marked (fallback)
      assert Enum.at(updated_team.coach.fouls, 0).is_last_of_half == true

      # Assistant coach should have no fouls
      assert updated_team.assistant_coach.fouls == []
    end

    test "handles teams with nil coaches gracefully" do
      player_foul = %FibaScoresheet.Foul{
        type: "P",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      player1 = %FibaScoresheet.Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [player_foul]
      }

      team = %FibaScoresheet.Team{
        name: "Some team",
        players: [player1],
        coach: nil,
        assistant_coach: nil,
        all_fouls: [],
        running_score: %{},
        score: 0
      }

      updated_team = TeamManager.mark_fouls_as_last_of_half(team, 2)

      # Player should have period 2 foul marked
      updated_player = Enum.find(updated_team.players, fn p -> p.id == "123" end)
      assert Enum.at(updated_player.fouls, 0).is_last_of_half == true

      # Coaches should remain nil
      assert updated_team.coach == nil
      assert updated_team.assistant_coach == nil
    end
  end
end
