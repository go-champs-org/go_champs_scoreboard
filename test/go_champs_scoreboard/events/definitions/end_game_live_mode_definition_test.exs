defmodule GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition
  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState}

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               EndGameLiveModeDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{key: "end-game-live-mode", game_id: "some-game-id"} =
               EndGameLiveModeDefinition.create("some-game-id", %{})
    end
  end

  describe "handle/2" do
    test "updates live_state to :ended in GameState" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        live_state: %LiveState{state: :in_progress, started_at: NaiveDateTime.utc_now()}
      }

      game =
        EndGameLiveModeDefinition.handle(
          game_state,
          nil
        )

      assert game.live_state.state == :ended
      assert game.live_state.started_at != nil

      current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      ended_at_truncated = game.live_state.ended_at |> NaiveDateTime.truncate(:second)
      assert ended_at_truncated == current_time
    end
  end
end
