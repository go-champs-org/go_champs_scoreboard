defmodule GoChampsScoreboard.Events.Definitions.GameTickDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.GameTickDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               GameTickDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns an event" do
      assert %Event{
               key: "game-tick",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               GameTickDefinition.create("some-game-id", 10, 1, %{})
    end
  end

  describe "handle/1" do
    test "returns the game state with updated game clock for basketball" do
      game_state = %GameState{
        id: "1",
        sport_id: "basketball",
        clock_state: %GameClockState{
          time: 10,
          period: 1,
          state: :running
        },
        away_team: %{
          players: []
        },
        home_team: %{
          players: []
        }
      }

      game = GameTickDefinition.handle(game_state)

      assert game.clock_state.time == 9
      assert game.clock_state.period == 1
      assert game.clock_state.state == :running
    end

    test "returns the game state with update players for basketball" do
      game_state = %GameState{
        id: "1",
        sport_id: "basketball",
        clock_state: %GameClockState{
          time: 10,
          period: 1,
          state: :running
        },
        home_team: %{
          players: [
            %{id: "player1", state: :playing, stats_values: %{"minutes_played" => 0}},
            %{id: "player2", state: :playing, stats_values: %{"minutes_played" => 2}}
          ]
        },
        away_team: %{
          players: [
            %{id: "player3", state: :playing, stats_values: %{"minutes_played" => 0}},
            %{id: "player4", state: :playing, stats_values: %{"minutes_played" => 2}}
          ]
        }
      }

      game = GameTickDefinition.handle(game_state)

      assert game.home_team.players == [
               %{id: "player1", state: :playing, stats_values: %{"minutes_played" => 1}},
               %{id: "player2", state: :playing, stats_values: %{"minutes_played" => 3}}
             ]

      assert game.away_team.players == [
               %{id: "player3", state: :playing, stats_values: %{"minutes_played" => 1}},
               %{id: "player4", state: :playing, stats_values: %{"minutes_played" => 3}}
             ]
    end
  end
end
