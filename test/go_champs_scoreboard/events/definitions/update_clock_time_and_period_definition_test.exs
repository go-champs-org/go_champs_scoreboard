defmodule GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.{GameState, TeamState}

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               UpdateClockTimeAndPeriodDefinition.validate(game_state, %{
                 "property" => "time",
                 "operation" => "increment"
               })
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "update-clock-time-and-period",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdateClockTimeAndPeriodDefinition.create("some-game-id", 10, 1, %{
                 "property" => "time",
                 "operation" => "increment"
               })
    end
  end

  describe "handle/2" do
    test "returns the game state with increased time" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 100,
          period: 1,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "time",
        "operation" => "increment"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 101,
                 period: 1,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with time equals to initial period time when time would be greater than initial period time" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          initial_period_time: 100,
          time: 100,
          period: 1
        }
      }

      update_player_in_team_payload = %{
        "property" => "time",
        "operation" => "increment"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 initial_period_time: 100,
                 time: 100,
                 period: 1
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with increased time by 60" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 100,
          period: 1,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "time",
        "operation" => "increment60"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 160,
                 period: 1,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with decreased time" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 100,
          period: 1,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "time",
        "operation" => "decrement"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 99,
                 period: 1,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with decreased time by 60" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 100,
          period: 1,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "time",
        "operation" => "decrement60"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 40,
                 period: 1,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with time 0 when time would be negative" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 0,
          period: 1,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "time",
        "operation" => "decrement"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 0,
                 period: 1,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with increased period" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 100,
          period: 1,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "period",
        "operation" => "increment"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 100,
                 period: 2,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end

    test "returns the game state with decreased period" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        clock_state: %{
          time: 100,
          period: 4,
          initial_period_time: 200
        }
      }

      update_player_in_team_payload = %{
        "property" => "period",
        "operation" => "decrement"
      }

      event =
        UpdateClockTimeAndPeriodDefinition.create(
          game_state.id,
          10,
          1,
          update_player_in_team_payload
        )

      assert %GameState{
               id: "1",
               away_team: %TeamState{
                 players: []
               },
               home_team: %TeamState{
                 players: []
               },
               clock_state: %{
                 time: 100,
                 period: 3,
                 initial_period_time: 200
               }
             } =
               UpdateClockTimeAndPeriodDefinition.handle(game_state, event)
    end
  end
end
