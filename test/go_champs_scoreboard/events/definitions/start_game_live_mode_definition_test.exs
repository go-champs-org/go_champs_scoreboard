defmodule GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState}

  alias GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Models.Event

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               StartGameLiveModeDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "start-game-live-mode",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               StartGameLiveModeDefinition.create("some-game-id", 10, 1, %{})
    end
  end

  describe "handle/2" do
    test "updates live_mode to :in_progress and started_at in GameState" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        live_state: %LiveState{state: :not_started, started_at: nil}
      }

      game =
        StartGameLiveModeDefinition.handle(
          game_state,
          %{}
        )

      assert game.live_state.state == :in_progress
      current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      started_at_truncated = game.live_state.started_at |> NaiveDateTime.truncate(:second)
      assert started_at_truncated == current_time
    end
  end
end
