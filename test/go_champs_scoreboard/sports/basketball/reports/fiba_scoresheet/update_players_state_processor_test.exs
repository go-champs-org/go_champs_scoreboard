defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayersStateProcessorTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayersStateProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  describe "process/2" do
    test "updates multiple players to playing state" do
      event_log = %EventLog{
        game_clock_period: 2,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1", "player-2"],
          "state" => "playing"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: false,
          has_started: false,
          first_played_period: 0
        },
        %FibaScoresheet.Player{
          id: "player-2",
          name: "Player 2",
          number: "11",
          has_played: false,
          has_started: false,
          first_played_period: 0
        },
        %FibaScoresheet.Player{
          id: "player-3",
          name: "Player 3",
          number: "12",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      team_b_players = [
        %FibaScoresheet.Player{
          id: "player-4",
          name: "Player 4",
          number: "20",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: team_b_players}
      }

      result = UpdatePlayersStateProcessor.process(event_log, fiba_scoresheet)

      updated_player_1 = Enum.find(result.team_a.players, &(&1.id == "player-1"))
      updated_player_2 = Enum.find(result.team_a.players, &(&1.id == "player-2"))
      unchanged_player_3 = Enum.find(result.team_a.players, &(&1.id == "player-3"))
      unchanged_player_4 = Enum.find(result.team_b.players, &(&1.id == "player-4"))

      assert updated_player_1.has_played == true
      assert updated_player_1.first_played_period == 2

      assert updated_player_2.has_played == true
      assert updated_player_2.first_played_period == 2

      assert unchanged_player_3.has_played == false
      assert unchanged_player_3.first_played_period == 0

      assert unchanged_player_4.has_played == false
      assert unchanged_player_4.first_played_period == 0
    end

    test "keeps original first_played_period for players who already have has_played = true" do
      event_log = %EventLog{
        game_clock_period: 3,
        payload: %{
          "team-type" => "away",
          "player-ids" => ["player-1"],
          "state" => "playing"
        }
      }

      team_b_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: true,
          has_started: false,
          first_played_period: 1
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: []},
        team_b: %FibaScoresheet.Team{players: team_b_players}
      }

      result = UpdatePlayersStateProcessor.process(event_log, fiba_scoresheet)

      updated_player = Enum.find(result.team_b.players, &(&1.id == "player-1"))

      assert updated_player.has_played == true
      assert updated_player.first_played_period == 1
    end

    test "does not update players when state is not 'playing'" do
      event_log = %EventLog{
        game_clock_period: 2,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1"],
          "state" => "bench"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: []}
      }

      result = UpdatePlayersStateProcessor.process(event_log, fiba_scoresheet)

      unchanged_player = Enum.find(result.team_a.players, &(&1.id == "player-1"))

      assert unchanged_player.has_played == false
      assert unchanged_player.first_played_period == 0
    end

    test "handles empty player-ids list" do
      event_log = %EventLog{
        game_clock_period: 2,
        payload: %{
          "team-type" => "home",
          "player-ids" => [],
          "state" => "playing"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: []}
      }

      result = UpdatePlayersStateProcessor.process(event_log, fiba_scoresheet)

      unchanged_player = Enum.find(result.team_a.players, &(&1.id == "player-1"))

      assert unchanged_player.has_played == false
      assert unchanged_player.first_played_period == 0
    end

    test "updates only players with matching IDs" do
      event_log = %EventLog{
        game_clock_period: 1,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1", "non-existent-player"],
          "state" => "playing"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: false,
          has_started: false,
          first_played_period: 0
        },
        %FibaScoresheet.Player{
          id: "player-2",
          name: "Player 2",
          number: "11",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: []}
      }

      result = UpdatePlayersStateProcessor.process(event_log, fiba_scoresheet)

      updated_player_1 = Enum.find(result.team_a.players, &(&1.id == "player-1"))
      unchanged_player_2 = Enum.find(result.team_a.players, &(&1.id == "player-2"))

      assert updated_player_1.has_played == true
      assert updated_player_1.first_played_period == 1

      assert unchanged_player_2.has_played == false
      assert unchanged_player_2.first_played_period == 0
    end

    test "preserves other player attributes when updating" do
      event_log = %EventLog{
        game_clock_period: 4,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1"],
          "state" => "playing"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "John Doe",
          number: "23",
          fouls: [],
          license_number: "12345",
          has_played: false,
          has_started: true,
          first_played_period: 0,
          is_captain: false
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: []}
      }

      result = UpdatePlayersStateProcessor.process(event_log, fiba_scoresheet)

      updated_player = Enum.find(result.team_a.players, &(&1.id == "player-1"))

      assert updated_player.has_played == true
      assert updated_player.first_played_period == 4

      assert updated_player.name == "John Doe"
      assert updated_player.number == "23"
      assert updated_player.fouls == []
      assert updated_player.license_number == "12345"
      assert updated_player.has_started == true
      assert updated_player.is_captain == false
    end

    test "handles different team types correctly" do
      event_log_home = %EventLog{
        game_clock_period: 2,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1"],
          "state" => "playing"
        }
      }

      event_log_away = %EventLog{
        game_clock_period: 3,
        payload: %{
          "team-type" => "away",
          "player-ids" => ["player-2"],
          "state" => "playing"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      team_b_players = [
        %FibaScoresheet.Player{
          id: "player-2",
          name: "Player 2",
          number: "20",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: team_b_players}
      }

      result_home = UpdatePlayersStateProcessor.process(event_log_home, fiba_scoresheet)

      result_away = UpdatePlayersStateProcessor.process(event_log_away, result_home)

      updated_player_1 = Enum.find(result_away.team_a.players, &(&1.id == "player-1"))
      updated_player_2 = Enum.find(result_away.team_b.players, &(&1.id == "player-2"))

      assert updated_player_1.has_played == true
      assert updated_player_1.first_played_period == 2

      assert updated_player_2.has_played == true
      assert updated_player_2.first_played_period == 3
    end

    test "preserves first_played_period when updating already played players multiple times" do
      event_log_1 = %EventLog{
        game_clock_period: 1,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1"],
          "state" => "playing"
        }
      }

      event_log_2 = %EventLog{
        game_clock_period: 3,
        payload: %{
          "team-type" => "home",
          "player-ids" => ["player-1"],
          "state" => "playing"
        }
      }

      team_a_players = [
        %FibaScoresheet.Player{
          id: "player-1",
          name: "Player 1",
          number: "10",
          has_played: false,
          has_started: false,
          first_played_period: 0
        }
      ]

      fiba_scoresheet = %FibaScoresheet{
        team_a: %FibaScoresheet.Team{players: team_a_players},
        team_b: %FibaScoresheet.Team{players: []}
      }

      result_1 = UpdatePlayersStateProcessor.process(event_log_1, fiba_scoresheet)

      result_2 = UpdatePlayersStateProcessor.process(event_log_2, result_1)

      updated_player = Enum.find(result_2.team_a.players, &(&1.id == "player-1"))

      assert updated_player.has_played == true
      assert updated_player.first_played_period == 1
    end
  end
end
