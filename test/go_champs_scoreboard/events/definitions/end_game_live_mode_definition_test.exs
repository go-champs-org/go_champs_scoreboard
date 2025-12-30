defmodule GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition
  alias GoChampsScoreboard.Games.Models.{GameState, LiveState, TeamState, InfoState}

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               EndGameLiveModeDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "end-game-live-mode",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               EndGameLiveModeDefinition.create("some-game-id", 10, 1, %{})
    end

    test "returns event with assets" do
      assert %Event{
               key: "end-game-live-mode",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1,
               payload: %{
                 "assets" => [
                   %{"type" => "logo", "url" => "http://example.com/logo1.png"},
                   %{"type" => "banner", "url" => "http://example.com/banner1.png"}
                 ]
               }
             } =
               EndGameLiveModeDefinition.create("some-game-id", 10, 1, %{
                 "assets" => [
                   %{"type" => "logo", "url" => "http://example.com/logo1.png"},
                   %{"type" => "banner", "url" => "http://example.com/banner1.png"}
                 ]
               })
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
          Event.new("end-game-live-mode", "1", 10, 1, nil)
        )

      assert game.live_state.state == :ended
      assert game.live_state.started_at != nil

      current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      ended_at_truncated = game.live_state.ended_at |> NaiveDateTime.truncate(:second)
      assert ended_at_truncated == current_time
    end

    test "updates info with assets" do
      game_state = %GameState{
        id: "1",
        away_team: %TeamState{
          players: []
        },
        home_team: %TeamState{
          players: []
        },
        live_state: %LiveState{state: :in_progress, started_at: NaiveDateTime.utc_now()},
        info: %InfoState{
          assets: []
        }
      }

      event = %Event{
        key: "end-game-live-mode",
        game_id: "1",
        clock_state_time_at: 10,
        clock_state_period_at: 1,
        payload: %{
          "assets" => [
            %{"type" => "logo", "url" => "http://example.com/logo1.png"},
            %{"type" => "banner", "url" => "http://example.com/banner1.png"}
          ]
        }
      }

      updated_game_state =
        EndGameLiveModeDefinition.handle(
          game_state,
          event
        )

      assert updated_game_state.live_state.state == :ended
      assert updated_game_state.live_state.started_at != nil

      current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      ended_at_truncated =
        updated_game_state.live_state.ended_at |> NaiveDateTime.truncate(:second)

      assert ended_at_truncated == current_time

      assert updated_game_state.info.assets == [
               %{type: "banner", url: "http://example.com/banner1.png"},
               %{type: "logo", url: "http://example.com/logo1.png"}
             ]
    end
  end
end
