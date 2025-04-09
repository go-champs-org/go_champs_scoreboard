defmodule GoChampsScoreboard.Games.TeamsTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Statistics.Models.Stat

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
end
