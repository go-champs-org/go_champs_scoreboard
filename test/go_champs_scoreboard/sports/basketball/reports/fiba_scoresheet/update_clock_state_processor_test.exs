defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateClockStateProcessorTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateClockStateProcessor
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  describe "process/2" do
    test "marks playing players as started when all conditions are met" do
      event_log = %EventLog{
        game_clock_time: 600,
        game_clock_period: 1,
        payload: %{"state" => "running"},
        snapshot: %{
          state: %{
            home_team: %{
              players: [
                %{id: "player-1", state: :playing},
                %{id: "player-2", state: :playing},
                %{id: "player-3", state: :bench},
                %{id: "player-4", state: :not_available}
              ]
            },
            away_team: %{
              players: [
                %{id: "player-5", state: :playing},
                %{id: "player-6", state: :bench}
              ]
            }
          }
        }
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-1",
              has_played: false,
              has_started: false,
              first_played_period: 0
            },
            %FibaScoresheet.Player{
              id: "player-2",
              has_played: false,
              has_started: false,
              first_played_period: 0
            },
            %FibaScoresheet.Player{
              id: "player-3",
              has_played: false,
              has_started: false,
              first_played_period: 0
            },
            %FibaScoresheet.Player{
              id: "player-4",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        },
        team_b: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-5",
              has_played: false,
              has_started: false,
              first_played_period: 0
            },
            %FibaScoresheet.Player{
              id: "player-6",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      team_a_playing_player_1 = Enum.find(result.team_a.players, &(&1.id == "player-1"))
      team_a_playing_player_2 = Enum.find(result.team_a.players, &(&1.id == "player-2"))
      team_a_bench_player = Enum.find(result.team_a.players, &(&1.id == "player-3"))
      team_a_not_available_player = Enum.find(result.team_a.players, &(&1.id == "player-4"))

      assert team_a_playing_player_1.has_played == true
      assert team_a_playing_player_1.has_started == true
      assert team_a_playing_player_1.first_played_period == 1

      assert team_a_playing_player_2.has_played == true
      assert team_a_playing_player_2.has_started == true
      assert team_a_playing_player_2.first_played_period == 1

      assert team_a_bench_player.has_played == false
      assert team_a_bench_player.has_started == false
      assert team_a_bench_player.first_played_period == 0

      assert team_a_not_available_player.has_played == false
      assert team_a_not_available_player.has_started == false
      assert team_a_not_available_player.first_played_period == 0

      # Check team_b players
      team_b_playing_player = Enum.find(result.team_b.players, &(&1.id == "player-5"))
      team_b_bench_player = Enum.find(result.team_b.players, &(&1.id == "player-6"))

      # Playing player should be marked as started
      assert team_b_playing_player.has_played == true
      assert team_b_playing_player.has_started == true
      assert team_b_playing_player.first_played_period == 1

      # Bench player should remain unchanged
      assert team_b_bench_player.has_played == false
      assert team_b_bench_player.has_started == false
      assert team_b_bench_player.first_played_period == 0
    end

    test "does not update players when game clock time does not match initial period time" do
      event_log = %EventLog{
        # Different from initial_period_time
        game_clock_time: 500,
        game_clock_period: 1,
        payload: %{"state" => "running"},
        snapshot: %{state: %{home_team: %{players: []}, away_team: %{players: []}}}
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-1",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        },
        team_b: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-2",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      # Data should remain unchanged
      assert result == data
    end

    test "does not update players when game clock period is not 1" do
      event_log = %EventLog{
        game_clock_time: 600,
        # Not period 1
        game_clock_period: 2,
        payload: %{"state" => "running"},
        snapshot: %{state: %{home_team: %{players: []}, away_team: %{players: []}}}
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-1",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        },
        team_b: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-2",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      # Data should remain unchanged
      assert result == data
    end

    test "does not update players when payload state is not 'running'" do
      event_log = %EventLog{
        game_clock_time: 600,
        game_clock_period: 1,
        # Not "running"
        payload: %{"state" => "paused"},
        snapshot: %{state: %{home_team: %{players: []}, away_team: %{players: []}}}
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-1",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        },
        team_b: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-2",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      # Data should remain unchanged
      assert result == data
    end

    test "does not update players when payload state is missing" do
      event_log = %EventLog{
        game_clock_time: 600,
        game_clock_period: 1,
        # No state key
        payload: %{},
        snapshot: %{state: %{home_team: %{players: []}, away_team: %{players: []}}}
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-1",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        },
        team_b: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-2",
              has_played: false,
              has_started: false,
              first_played_period: 0
            }
          ]
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      # Data should remain unchanged
      assert result == data
    end

    test "handles empty player lists" do
      event_log = %EventLog{
        game_clock_time: 600,
        game_clock_period: 1,
        payload: %{"state" => "running"},
        snapshot: %{state: %{home_team: %{players: []}, away_team: %{players: []}}}
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: []
        },
        team_b: %FibaScoresheet.Team{
          players: []
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      # Should not crash and return data with empty player lists
      assert result.team_a.players == []
      assert result.team_b.players == []
    end

    test "preserves other player attributes when updating starting players" do
      event_log = %EventLog{
        game_clock_time: 600,
        game_clock_period: 1,
        payload: %{"state" => "running"},
        snapshot: %{
          state: %{
            home_team: %{
              players: [
                %{id: "player-1", state: :playing}
              ]
            },
            away_team: %{players: []}
          }
        }
      }

      data = %FibaScoresheet{
        info: %FibaScoresheet.Info{
          initial_period_time: 600
        },
        team_a: %FibaScoresheet.Team{
          players: [
            %FibaScoresheet.Player{
              id: "player-1",
              has_played: false,
              has_started: false,
              first_played_period: 0,
              name: "John Doe",
              number: "10"
            }
          ]
        },
        team_b: %FibaScoresheet.Team{
          players: []
        }
      }

      result = UpdateClockStateProcessor.process(event_log, data)

      updated_player = Enum.find(result.team_a.players, &(&1.id == "player-1"))

      assert updated_player.has_played == true
      assert updated_player.has_started == true
      assert updated_player.first_played_period == 1

      assert updated_player.name == "John Doe"
      assert updated_player.number == "10"
      assert updated_player.id == "player-1"
    end
  end
end
