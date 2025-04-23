defmodule GoChampsScoreboard.Events.Definitions.ResetGameLiveModeDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState}

  alias GoChampsScoreboard.Events.Definitions.ResetGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Models.Event

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               ResetGameLiveModeDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "reset-game-live-mode",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               ResetGameLiveModeDefinition.create("some-game-id", 10, 1, %{})
    end
  end

  describe "handle/2" do
    test "updates live_mode to :in_progress in GameState" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        live_state: %LiveState{state: :ended}
      }

      game =
        ResetGameLiveModeDefinition.handle(
          game_state,
          %{}
        )

      assert game.live_state.state == :not_started
    end
  end
end
