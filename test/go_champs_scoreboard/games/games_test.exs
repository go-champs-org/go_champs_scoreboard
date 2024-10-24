defmodule GoChampsScoreboard.Games.GamesTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState

  import Mox

  setup :verify_on_exit!

  @http_client GoChampsScoreboard.HTTPClientMock

  describe "find_or_bootstrap/1 when game is set" do
    test "returns game_state" do
      set_test_game()

      result_game_state = Games.find_or_bootstrap("some-game-id")

      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Some home team"

      unset_test_game()
    end
  end

  describe "find_or_bootstrap/1 when game is not set" do
    test "bootstraps game from go champs, store it and returns it" do
      set_go_champs_api_respose()

      result_game_state = Games.find_or_bootstrap("some-game-id")

      {:ok, stored_game} = Redix.command(:games_cache, ["GET", "some-game-id"])

      redis_game = GameState.from_json(stored_game)

      assert redis_game.id == "some-game-id"
      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Go champs away team"
      assert result_game_state.home_team.name == "Go champs home team"

      unset_test_game()
    end
  end

  describe "update_team" do
    test "return a game state with given updated team" do
      game_state = %GameState{
        id: "some-game-id",
        away_team: %TeamState{name: "Some away team"},
        home_team: %TeamState{name: "Some home team"}
      }

      updated_team = %TeamState{name: "Updated home team"}

      result_game_state = Games.update_team(game_state, "home", updated_team)

      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Updated home team"
    end
  end

  describe "update_clock_state" do
    test "return a game state with given updated clock state" do
      game_state = %GameState{
        id: "some-game-id",
        away_team: %TeamState{name: "Some away team"},
        home_team: %TeamState{name: "Some home team"},
        clock_state: %GameClockState{time: 10, period: 1, state: :running}
      }

      updated_clock_state = %GameClockState{time: 9, period: 1, state: :running}

      result_game_state = Games.update_clock_state(game_state, updated_clock_state)

      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Some home team"
      assert result_game_state.clock_state.time == 9
      assert result_game_state.clock_state.period == 1
      assert result_game_state.clock_state.state == :running
    end
  end

  defp set_go_champs_api_respose() do
    response_body = %{
      "data" => %{
        "id" => "some-game-id",
        "away_team" => %{
          "name" => "Go champs away team"
        },
        "home_team" => %{
          "name" => "Go champs home team"
        }
      }
    }

    expect(@http_client, :get, fn url ->
      assert url =~ "some-game-id"

      {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
    end)
  end

  defp set_test_game() do
    away_team = TeamState.new("Some away team")
    home_team = TeamState.new("Some home team")
    clock_state = GameClockState.new()
    game_state = GameState.new("some-game-id", away_team, home_team, clock_state)
    Redix.command(:games_cache, ["SET", "some-game-id", game_state])
  end

  defp unset_test_game() do
    Redix.command(:games_cache, ["DEL", "some-game-id"])
  end
end
