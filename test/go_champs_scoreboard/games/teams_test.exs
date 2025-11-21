defmodule GoChampsScoreboard.Games.TeamsTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Statistics.Models.Stat

  describe "add_coach" do
    test "adds a coach to the given team" do
      game_state = %GameState{
        home_team: %TeamState{
          name: "Brazil",
          coaches: []
        }
      }

      coach = %CoachState{
        id: 1,
        name: "Tite",
        type: :head_coach
      }

      assert %GameState{
               home_team: %TeamState{
                 name: "Brazil",
                 coaches: [
                   %CoachState{
                     id: 1,
                     name: "Tite",
                     type: :head_coach
                   }
                 ]
               }
             } == Teams.add_coach(game_state, "home", coach)
    end
  end

  describe "add_coach_to_team" do
    test "adds a coach to the given team" do
      team = %TeamState{
        name: "Brazil",
        coaches: []
      }

      coach = %CoachState{
        id: 1,
        name: "Tite",
        type: :head_coach
      }

      assert %TeamState{
               name: "Brazil",
               coaches: [
                 %CoachState{
                   id: 1,
                   name: "Tite",
                   type: :head_coach
                 }
               ]
             } == Teams.add_coach_to_team(team, coach)
    end
  end

  describe "add_player" do
    test "adds a player to the given team" do
      game_state = %GameState{
        home_team: %TeamState{
          name: "Brazil",
          players: [
            %PlayerState{
              id: 1,
              name: "Pelé",
              stats_values: %{
                "goals" => 1000,
                "assists" => 500
              }
            }
          ]
        }
      }

      player = %PlayerState{
        id: 10,
        name: "Garrincha",
        stats_values: %{
          "goals" => 100,
          "assists" => 50
        }
      }

      assert %GameState{
               home_team: %TeamState{
                 name: "Brazil",
                 players: [
                   %PlayerState{
                     id: 10,
                     name: "Garrincha",
                     stats_values: %{
                       "goals" => 100,
                       "assists" => 50
                     }
                   },
                   %PlayerState{
                     id: 1,
                     name: "Pelé",
                     stats_values: %{
                       "goals" => 1000,
                       "assists" => 500
                     }
                   }
                 ]
               }
             } == Teams.add_player(game_state, "home", player)
    end
  end

  describe "add_player_to_team" do
    test "adds a player to the given team" do
      team = %TeamState{
        name: "Brazil",
        players: [
          %PlayerState{
            id: 1,
            name: "Pelé",
            stats_values: %{
              "goals" => 1000,
              "assists" => 500
            }
          }
        ]
      }

      player = %PlayerState{
        id: 10,
        name: "Garrincha",
        stats_values: %{
          "goals" => 100,
          "assists" => 50
        }
      }

      assert %TeamState{
               name: "Brazil",
               players: [
                 %PlayerState{
                   id: 10,
                   name: "Garrincha",
                   stats_values: %{
                     "goals" => 100,
                     "assists" => 50
                   }
                 },
                 %PlayerState{
                   id: 1,
                   name: "Pelé",
                   stats_values: %{
                     "goals" => 1000,
                     "assists" => 500
                   }
                 }
               ]
             } == Teams.add_player_to_team(team, player)
    end
  end

  describe "find_coach" do
    test "returns the coach with the given team type and coach id" do
      game_state = %GameState{
        home_team: %TeamState{
          coaches: [
            %CoachState{
              id: 2,
              name: "Doc Rivers",
              stats_values: %{
                "fouls" => 2
              }
            }
          ]
        }
      }

      assert %CoachState{
               id: 2,
               name: "Doc Rivers",
               stats_values: %{
                 "fouls" => 2
               }
             } == Teams.find_coach(game_state, "home", 2)
    end
  end

  describe "find_player" do
    test "returns the player with the given team type and player id" do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: 1,
              name: "Pelé",
              stats_values: %{
                "goals" => 1000,
                "assists" => 500
              }
            }
          ]
        }
      }

      assert %PlayerState{
               id: 1,
               name: "Pelé",
               stats_values: %{
                 "goals" => 1000,
                 "assists" => 500
               }
             } == Teams.find_player(game_state, "home", 1)
    end
  end

  describe "find_team" do
    test "returns the home team if give team_type is 'home'" do
      game_state = %GameState{
        home_team: %TeamState{
          name: "Brazil",
          players: [
            %PlayerState{
              id: 1,
              name: "Pelé",
              stats_values: %{
                "goals" => 1000,
                "assists" => 500
              }
            }
          ]
        }
      }

      assert %TeamState{
               name: "Brazil",
               players: [
                 %PlayerState{
                   id: 1,
                   name: "Pelé",
                   stats_values: %{
                     "goals" => 1000,
                     "assists" => 500
                   }
                 }
               ]
             } == Teams.find_team(game_state, "home")
    end

    test "returns the away team if give team_type is 'away'" do
      game_state = %GameState{
        away_team: %TeamState{
          name: "Argentina",
          players: [
            %PlayerState{
              id: 10,
              name: "Maradona",
              stats_values: %{
                "goals" => 500,
                "assists" => 300
              }
            }
          ]
        }
      }

      assert %TeamState{
               name: "Argentina",
               players: [
                 %PlayerState{
                   id: 10,
                   name: "Maradona",
                   stats_values: %{
                     "goals" => 500,
                     "assists" => 300
                   }
                 }
               ]
             } == Teams.find_team(game_state, "away")
    end

    test "raises an error if the given team type is invalid" do
      game_state = %GameState{}

      assert_raise RuntimeError, "Invalid team type", fn ->
        Teams.find_team(game_state, "invalid")
      end
    end
  end

  describe "find_players" do
    test "returns the list of players for the given team type" do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: 1,
              name: "Pelé",
              stats_values: %{
                "goals" => 1000,
                "assists" => 500
              }
            },
            %PlayerState{
              id: 2,
              name: "Zico",
              stats_values: %{
                "goals" => 500,
                "assists" => 300
              }
            }
          ]
        }
      }

      assert [
               %PlayerState{
                 id: 1,
                 name: "Pelé",
                 stats_values: %{
                   "goals" => 1000,
                   "assists" => 500
                 }
               },
               %PlayerState{
                 id: 2,
                 name: "Zico",
                 stats_values: %{
                   "goals" => 500,
                   "assists" => 300
                 }
               }
             ] == Teams.find_players(game_state, "home")
    end
  end

  describe "update_player_in_team" do
    test "updates the player in the given team" do
      team = %TeamState{
        name: "Brazil",
        players: [
          %PlayerState{
            id: 1,
            name: "Pelé",
            stats_values: %{
              "goals" => 1000,
              "assists" => 500
            }
          }
        ]
      }

      player = %PlayerState{
        id: 1,
        name: "Garrincha",
        stats_values: %{
          "goals" => 1000,
          "assists" => 500
        }
      }

      assert %TeamState{
               name: "Brazil",
               players: [
                 %PlayerState{
                   id: 1,
                   name: "Garrincha",
                   stats_values: %{
                     "goals" => 1000,
                     "assists" => 500
                   }
                 }
               ]
             } == Teams.update_player_in_team(team, player)
    end
  end

  describe "update_coach_in_team" do
    test "updates the coach in the given team" do
      team = %TeamState{
        name: "Brazil",
        coaches: [
          %CoachState{
            id: 1,
            name: "Tite",
            type: :head_coach
          }
        ]
      }

      coach = %CoachState{
        id: 1,
        name: "Tite Updated",
        type: :assitant_coach
      }

      assert %TeamState{
               name: "Brazil",
               coaches: [
                 %CoachState{
                   id: 1,
                   name: "Tite Updated",
                   type: :assitant_coach
                 }
               ]
             } == Teams.update_coach_in_team(team, coach)
    end
  end

  describe "remove_coach" do
    test "removes the coach with the given team type and coach id" do
      game_state = %GameState{
        home_team: %TeamState{
          coaches: [
            %CoachState{
              id: 1,
              name: "Tite",
              type: :head_coach
            }
          ]
        }
      }

      assert %GameState{
               home_team: %TeamState{
                 coaches: []
               }
             } == Teams.remove_coach(game_state, "home", 1)
    end
  end

  describe "remove_coach_in_team" do
    test "removes the coach from the given team and coach id" do
      team = %TeamState{
        name: "Brazil",
        coaches: [
          %CoachState{
            id: 1,
            name: "Doc Rivers",
            type: :head_coach
          }
        ]
      }

      assert %TeamState{
               name: "Brazil",
               coaches: []
             } == Teams.remove_coach_in_team(team, 1)
    end
  end

  describe "remove_player" do
    test "removes the player with the given team type and player id" do
      game_state = %GameState{
        home_team: %TeamState{
          players: [
            %PlayerState{
              id: 1,
              name: "Pelé",
              stats_values: %{
                "goals" => 1000,
                "assists" => 500
              }
            }
          ]
        }
      }

      assert %GameState{
               home_team: %TeamState{
                 players: []
               }
             } == Teams.remove_player(game_state, "home", 1)
    end
  end

  describe "remove_player_in_team" do
    test "removes the player from the given team and player id" do
      team = %TeamState{
        name: "Brazil",
        players: [
          %PlayerState{
            id: 1,
            name: "Pelé",
            stats_values: %{
              "goals" => 1000,
              "assists" => 500
            }
          }
        ]
      }

      assert %TeamState{
               name: "Brazil",
               players: []
             } == Teams.remove_player_in_team(team, 1)
    end
  end

  describe "calculate_team_total_player_stats" do
    test "returns a team state with total_player_stats with the sum all players stats" do
      team = %TeamState{
        name: "Brazil",
        players: [
          %PlayerState{
            id: 1,
            name: "Pelé",
            stats_values: %{
              "goals" => 1000,
              "assists" => 500
            }
          },
          %PlayerState{
            id: 2,
            name: "Zico",
            stats_values: %{
              "goals" => 500,
              "assists" => 300
            }
          }
        ]
      }

      assert %TeamState{
               name: "Brazil",
               players: [
                 %PlayerState{
                   id: 1,
                   name: "Pelé",
                   stats_values: %{
                     "goals" => 1000,
                     "assists" => 500
                   }
                 },
                 %PlayerState{
                   id: 2,
                   name: "Zico",
                   stats_values: %{
                     "assists" => 300,
                     "goals" => 500
                   }
                 }
               ],
               total_player_stats: %{
                 "goals" => 1500,
                 "assists" => 800
               }
             } == Teams.calculate_team_total_player_stats(team)
    end
  end

  describe "calculate_team_total_coach_stats" do
    test "returns a team state with total_coach_stats with the sum of all coaches stats" do
      team = %TeamState{
        name: "Brazil",
        total_coach_stats: %{},
        coaches: [
          %CoachState{
            id: 1,
            name: "Tite",
            type: :head_coach,
            stats_values: %{
              "technical_fouls" => 2,
              "timeouts_called" => 3
            }
          },
          %CoachState{
            id: 2,
            name: "Assistant Coach",
            type: :assistant_coach,
            stats_values: %{
              "technical_fouls" => 1,
              "timeouts_called" => 1
            }
          }
        ]
      }

      result = Teams.calculate_team_total_coach_stats(team)

      assert result.total_coach_stats == %{
               "technical_fouls" => 3,
               "timeouts_called" => 4
             }

      # Verify other fields remain unchanged
      assert result.name == "Brazil"
      assert length(result.coaches) == 2
    end

    test "returns empty map when no coaches present" do
      team = %TeamState{
        name: "Brazil",
        total_coach_stats: %{},
        coaches: []
      }

      result = Teams.calculate_team_total_coach_stats(team)

      assert result.total_coach_stats == %{}
    end

    test "handles coaches with empty stats_values" do
      team = %TeamState{
        name: "Brazil",
        total_coach_stats: %{},
        coaches: [
          %CoachState{
            id: 1,
            name: "Tite",
            type: :head_coach,
            stats_values: %{}
          }
        ]
      }

      result = Teams.calculate_team_total_coach_stats(team)

      assert result.total_coach_stats == %{}
    end
  end

  describe "update_manual_stats_values" do
    test "updates the team state with the new value" do
      team_state = %{
        stats_values: %{
          "technical-fouls" => 1
        }
      }

      team_stat = Stat.new("technical-fouls", :manual, [:increment])

      assert %{
               stats_values: %{
                 "technical-fouls" => 2
               }
             } == Teams.update_manual_stats_values(team_state, team_stat, "increment")
    end
  end

  describe "update_calculated_stats_values" do
    test "updates the team state with the new value" do
      team_state = %{
        stats_values: %{
          "technical-fouls" => 1,
          "timeouts" => 2,
          "total-technical-fouls" => 1
        }
      }

      team_stats = [
        Stat.new(
          "total-technical-fouls",
          :calculated,
          [],
          fn team_state -> team_state.stats_values["technical-fouls"] + 1 end
        )
      ]

      assert %{
               stats_values: %{
                 "technical-fouls" => 1,
                 "timeouts" => 2,
                 "total-technical-fouls" => 2
               }
             } == Teams.update_calculated_stats_values(team_state, team_stats)
    end
  end

  describe "calculate_period_stats" do
    test "calculates period stats for the first period correctly" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 2, "fouls_technical" => 1},
        period_stats: %{}
      }

      result = Teams.calculate_period_stats(team_state, 1)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 2, "fouls_technical" => 1}
               }
             } = result
    end

    test "calculates period stats for subsequent periods using differential approach" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 3, "fouls_technical" => 2},
        period_stats: %{
          "1" => %{"timeouts" => 2, "fouls_technical" => 1}
        }
      }

      result = Teams.calculate_period_stats(team_state, 2)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 2, "fouls_technical" => 1},
                 "2" => %{"timeouts" => 1, "fouls_technical" => 1}
               }
             } = result
    end

    test "handles multiple periods correctly" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 4, "fouls_technical" => 3},
        period_stats: %{
          "1" => %{"timeouts" => 1, "fouls_technical" => 0},
          "2" => %{"timeouts" => 2, "fouls_technical" => 1}
        }
      }

      result = Teams.calculate_period_stats(team_state, 3)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 1, "fouls_technical" => 0},
                 "2" => %{"timeouts" => 2, "fouls_technical" => 1},
                 "3" => %{"timeouts" => 1, "fouls_technical" => 2}
               }
             } = result
    end

    test "handles stat corrections with negative values" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 2, "fouls_technical" => 1},
        period_stats: %{
          "1" => %{"timeouts" => 2, "fouls_technical" => 1},
          "2" => %{"timeouts" => 1, "fouls_technical" => 1}
        }
      }

      result = Teams.calculate_period_stats(team_state, 3)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 2, "fouls_technical" => 1},
                 "2" => %{"timeouts" => 1, "fouls_technical" => 1},
                 "3" => %{"timeouts" => -1, "fouls_technical" => -1}
               }
             } = result
    end

    test "adds period even when no stats change" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 2, "fouls_technical" => 1},
        period_stats: %{
          "1" => %{"timeouts" => 2, "fouls_technical" => 1}
        }
      }

      result = Teams.calculate_period_stats(team_state, 2)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 2, "fouls_technical" => 1},
                 "2" => %{"timeouts" => 0, "fouls_technical" => 0}
               }
             } = result
    end

    test "handles nil period_stats gracefully" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 1, "fouls_technical" => 0},
        period_stats: nil
      }

      result = Teams.calculate_period_stats(team_state, 1)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 1}
               }
             } = result
    end

    test "handles only zero stats for periods" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 0, "fouls_technical" => 0},
        period_stats: %{}
      }

      result = Teams.calculate_period_stats(team_state, 1)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 0, "fouls_technical" => 0}
               }
             } = result
    end

    test "handles out-of-order period calculations" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 3, "fouls_technical" => 2},
        period_stats: %{
          "1" => %{"timeouts" => 1, "fouls_technical" => 1},
          "3" => %{"timeouts" => 1, "fouls_technical" => 0}
        }
      }

      result = Teams.calculate_period_stats(team_state, 2)

      # Period 2 = current_totals - (period 1 totals) = {timeouts: 3, fouls: 2} - {timeouts: 1, fouls: 1}
      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 1, "fouls_technical" => 1},
                 "2" => %{"timeouts" => 2, "fouls_technical" => 1},
                 "3" => %{"timeouts" => 1, "fouls_technical" => 0}
               }
             } = result
    end

    test "updates existing period stats when recalculating same period" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 2, "fouls_technical" => 1},
        period_stats: %{
          "1" => %{"timeouts" => 1, "fouls_technical" => 1}
        }
      }

      result = Teams.calculate_period_stats(team_state, 1)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 2, "fouls_technical" => 1}
               }
             } = result
    end

    test "handles string period keys and converts to consistent format" do
      team_state = %TeamState{
        stats_values: %{"timeouts" => 3, "fouls_technical" => 2},
        period_stats: %{
          "1" => %{"timeouts" => 1, "fouls_technical" => 1},
          "2" => %{"timeouts" => 1, "fouls_technical" => 0}
        }
      }

      result = Teams.calculate_period_stats(team_state, 3)

      assert %{
               period_stats: %{
                 "1" => %{"timeouts" => 1, "fouls_technical" => 1},
                 "2" => %{"timeouts" => 1, "fouls_technical" => 0},
                 "3" => %{"timeouts" => 1, "fouls_technical" => 1}
               }
             } = result
    end
  end
end
