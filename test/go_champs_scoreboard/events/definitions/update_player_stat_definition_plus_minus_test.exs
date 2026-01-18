defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinitionPlusMinusTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, PlayerState}
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  describe "plus_minus calculation with game-level stats" do
    test "home team player makes field goal - all playing players get +2 on home, -2 on away" do
      game_state = %GameState{
        id: "game-1",
        sport_id: "basketball",
        clock_state: %GoChampsScoreboard.Games.Models.GameClockState{
          state: :stopped,
          time: 600,
          period: 1,
          initial_period_time: 600
        },
        home_team: %TeamState{
          name: "Home Team",
          players: [
            %PlayerState{
              id: "home-player-1",
              name: "Home Player 1",
              number: "1",
              state: :playing,
              stats_values: Basketball.bootstrap_player_stats()
            },
            %PlayerState{
              id: "home-player-2",
              name: "Home Player 2",
              number: "2",
              state: :playing,
              stats_values: Basketball.bootstrap_player_stats()
            },
            %PlayerState{
              id: "home-player-3",
              name: "Home Player 3",
              number: "3",
              state: :bench,
              stats_values: Basketball.bootstrap_player_stats()
            }
          ],
          coaches: [],
          total_player_stats: Basketball.bootstrap_player_stats(),
          total_coach_stats: Basketball.bootstrap_coach_stats(),
          stats_values: Basketball.bootstrap_team_stats(),
          period_stats: %{}
        },
        away_team: %TeamState{
          name: "Away Team",
          players: [
            %PlayerState{
              id: "away-player-1",
              name: "Away Player 1",
              number: "11",
              state: :playing,
              stats_values: Basketball.bootstrap_player_stats()
            },
            %PlayerState{
              id: "away-player-2",
              name: "Away Player 2",
              number: "12",
              state: :bench,
              stats_values: Basketball.bootstrap_player_stats()
            }
          ],
          coaches: [],
          total_player_stats: Basketball.bootstrap_player_stats(),
          total_coach_stats: Basketball.bootstrap_coach_stats(),
          stats_values: Basketball.bootstrap_team_stats(),
          period_stats: %{}
        }
      }

      # Home player 1 makes a field goal (2 points)
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "field_goals_made"
      }

      event = UpdatePlayerStatDefinition.create("game-1", 590, 1, payload)
      new_game_state = UpdatePlayerStatDefinition.handle(game_state, event)

      # Check home team playing players got +2
      home_player_1 = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-1"))
      home_player_2 = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-2"))
      home_player_3 = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-3"))

      assert home_player_1.stats_values["plus_minus"] == 2
      assert home_player_2.stats_values["plus_minus"] == 2
      # Bench player unchanged
      assert home_player_3.stats_values["plus_minus"] == 0

      # Check away team playing players got -2
      away_player_1 = Enum.find(new_game_state.away_team.players, &(&1.id == "away-player-1"))
      away_player_2 = Enum.find(new_game_state.away_team.players, &(&1.id == "away-player-2"))

      assert away_player_1.stats_values["plus_minus"] == -2
      # Bench player unchanged
      assert away_player_2.stats_values["plus_minus"] == 0
    end

    test "three-pointer gives +3/-3 delta" do
      game_state = build_game_with_playing_players()

      payload = %{
        "operation" => "increment",
        "team-type" => "away",
        "player-id" => "away-player-1",
        "stat-id" => "three_point_field_goals_made"
      }

      event = UpdatePlayerStatDefinition.create("game-1", 500, 1, payload)
      new_game_state = UpdatePlayerStatDefinition.handle(game_state, event)

      # Away team playing players get +3
      away_player = Enum.find(new_game_state.away_team.players, &(&1.id == "away-player-1"))
      assert away_player.stats_values["plus_minus"] == 3

      # Home team playing players get -3
      home_player = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-1"))
      assert home_player.stats_values["plus_minus"] == -3
    end

    test "free throw gives +1/-1 delta" do
      game_state = build_game_with_playing_players()

      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "free_throws_made"
      }

      event = UpdatePlayerStatDefinition.create("game-1", 500, 1, payload)
      new_game_state = UpdatePlayerStatDefinition.handle(game_state, event)

      # Home team playing players get +1
      home_player = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-1"))
      assert home_player.stats_values["plus_minus"] == 1

      # Away team playing players get -1
      away_player = Enum.find(new_game_state.away_team.players, &(&1.id == "away-player-1"))
      assert away_player.stats_values["plus_minus"] == -1
    end

    test "decrement operation reverses the plus_minus" do
      # Start with players who already have plus_minus values
      game_state = build_game_with_playing_players()

      # Set initial plus_minus values
      game_state =
        put_in(
          game_state.home_team.players,
          Enum.map(game_state.home_team.players, fn player ->
            %{player | stats_values: Map.put(player.stats_values, "plus_minus", 5)}
          end)
        )

      game_state =
        put_in(
          game_state.away_team.players,
          Enum.map(game_state.away_team.players, fn player ->
            %{player | stats_values: Map.put(player.stats_values, "plus_minus", -3)}
          end)
        )

      # Decrement a field goal (undo 2 points)
      payload = %{
        "operation" => "decrement",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "field_goals_made"
      }

      event = UpdatePlayerStatDefinition.create("game-1", 500, 1, payload)
      new_game_state = UpdatePlayerStatDefinition.handle(game_state, event)

      # Home team playing players: 5 + (-2) = 3
      home_player = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-1"))
      assert home_player.stats_values["plus_minus"] == 3

      # Away team playing players: -3 + 2 = -1
      away_player = Enum.find(new_game_state.away_team.players, &(&1.id == "away-player-1"))
      assert away_player.stats_values["plus_minus"] == -1
    end

    test "plus_minus accumulates over multiple scoring events" do
      game_state = build_game_with_playing_players()

      # Event 1: Home makes field goal (+2)
      payload1 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "field_goals_made"
      }

      event1 = UpdatePlayerStatDefinition.create("game-1", 590, 1, payload1)
      game_state = UpdatePlayerStatDefinition.handle(game_state, event1)

      # Event 2: Away makes three-pointer (+3 for away, -3 for home)
      payload2 = %{
        "operation" => "increment",
        "team-type" => "away",
        "player-id" => "away-player-1",
        "stat-id" => "three_point_field_goals_made"
      }

      event2 = UpdatePlayerStatDefinition.create("game-1", 580, 1, payload2)
      game_state = UpdatePlayerStatDefinition.handle(game_state, event2)

      # Event 3: Home makes free throw (+1)
      payload3 = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "free_throws_made"
      }

      event3 = UpdatePlayerStatDefinition.create("game-1", 570, 1, payload3)
      game_state = UpdatePlayerStatDefinition.handle(game_state, event3)

      # Home player: +2 -3 +1 = 0
      home_player = Enum.find(game_state.home_team.players, &(&1.id == "home-player-1"))
      assert home_player.stats_values["plus_minus"] == 0

      # Away player: -2 +3 -1 = 0
      away_player = Enum.find(game_state.away_team.players, &(&1.id == "away-player-1"))
      assert away_player.stats_values["plus_minus"] == 0
    end

    test "non-scoring stats don't affect plus_minus" do
      game_state = build_game_with_playing_players()

      # Update a non-scoring stat (rebounds)
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "rebounds_defensive"
      }

      event = UpdatePlayerStatDefinition.create("game-1", 500, 1, payload)
      new_game_state = UpdatePlayerStatDefinition.handle(game_state, event)

      # Plus_minus should remain 0 for all players
      home_player = Enum.find(new_game_state.home_team.players, &(&1.id == "home-player-1"))
      assert home_player.stats_values["plus_minus"] == 0

      away_player = Enum.find(new_game_state.away_team.players, &(&1.id == "away-player-1"))
      assert away_player.stats_values["plus_minus"] == 0
    end

    test "only playing players affected, not bench players" do
      game_state = build_game_with_playing_players()

      # Home makes field goal
      payload = %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "home-player-1",
        "stat-id" => "field_goals_made"
      }

      event = UpdatePlayerStatDefinition.create("game-1", 500, 1, payload)
      new_game_state = UpdatePlayerStatDefinition.handle(game_state, event)

      # Playing player affected
      home_playing = Enum.find(new_game_state.home_team.players, &(&1.state == :playing))
      assert home_playing.stats_values["plus_minus"] == 2

      # Bench player not affected
      home_bench = Enum.find(new_game_state.home_team.players, &(&1.state == :bench))
      assert home_bench.stats_values["plus_minus"] == 0
    end
  end

  # Helper function to build a consistent game state
  defp build_game_with_playing_players do
    %GameState{
      id: "game-1",
      sport_id: "basketball",
      clock_state: %GoChampsScoreboard.Games.Models.GameClockState{
        state: :stopped,
        time: 600,
        period: 1,
        initial_period_time: 600
      },
      home_team: %TeamState{
        name: "Home Team",
        players: [
          %PlayerState{
            id: "home-player-1",
            name: "Home Player 1",
            number: "1",
            state: :playing,
            stats_values: Basketball.bootstrap_player_stats()
          },
          %PlayerState{
            id: "home-player-bench",
            name: "Home Player Bench",
            number: "10",
            state: :bench,
            stats_values: Basketball.bootstrap_player_stats()
          }
        ],
        coaches: [],
        total_player_stats: Basketball.bootstrap_player_stats(),
        total_coach_stats: Basketball.bootstrap_coach_stats(),
        stats_values: Basketball.bootstrap_team_stats(),
        period_stats: %{}
      },
      away_team: %TeamState{
        name: "Away Team",
        players: [
          %PlayerState{
            id: "away-player-1",
            name: "Away Player 1",
            number: "11",
            state: :playing,
            stats_values: Basketball.bootstrap_player_stats()
          },
          %PlayerState{
            id: "away-player-bench",
            name: "Away Player Bench",
            number: "20",
            state: :bench,
            stats_values: Basketball.bootstrap_player_stats()
          }
        ],
        coaches: [],
        total_player_stats: Basketball.bootstrap_player_stats(),
        total_coach_stats: Basketball.bootstrap_coach_stats(),
        stats_values: Basketball.bootstrap_team_stats(),
        period_stats: %{}
      }
    }
  end
end
