defmodule GoChampsScoreboard.Games.GamesTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateClockStateDefinition
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Models.{GameState, GameClockState, LiveState, TeamState}

  import Mox

  setup :verify_on_exit!

  @http_client GoChampsScoreboard.HTTPClientMock
  @resource_manager GoChampsScoreboard.Games.ResourceManagerMock

  describe "find_or_bootstrap/1 when game is set" do
    test "returns game_state" do
      set_test_game(:in_progress)

      result_game_state = Games.find_or_bootstrap("some-game-id")

      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Some home team"

      unset_test_game()
    end

    test "returns bootstrapped game from go champs if current game is not_started" do
      set_test_game()
      # Let's say teams have been updated in Go Champs
      set_go_champs_api_respose("Go champs updated away team", "Go champs updated home team")
      set_go_champs_view_setting_api_response()

      result_game_state = Games.find_or_bootstrap("some-game-id", "token")

      {:ok, stored_game} = Redix.command(:games_cache, ["GET", "some-game-id"])

      redis_game = GameState.from_json(stored_game)

      assert redis_game.id == "some-game-id"
      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Go champs updated away team"
      assert result_game_state.home_team.name == "Go champs updated home team"

      unset_test_game()
    end

    test "return game from cache and restart resource manager if game is in progress" do
      set_test_game(:in_progress)

      expect(@resource_manager, :check_and_restart, fn game_id ->
        assert game_id == "some-game-id"

        :ok
      end)

      result_game_state = Games.find_or_bootstrap("some-game-id", "token", @resource_manager)

      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Some home team"

      unset_test_game()
    end
  end

  describe "find_or_bootstrap/1 when game is not set" do
    test "bootstraps game from go champs, store it and returns it" do
      set_go_champs_api_respose()
      set_go_champs_view_setting_api_response()

      result_game_state = Games.find_or_bootstrap("some-game-id", "token")

      {:ok, stored_game} = Redix.command(:games_cache, ["GET", "some-game-id"])

      redis_game = GameState.from_json(stored_game)

      assert redis_game.id == "some-game-id"
      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Go champs away team"
      assert result_game_state.home_team.name == "Go champs home team"

      unset_test_game()
    end
  end

  describe "start_live_mode/1" do
    test "starts up ResourceManager and returns a handled StartGameLiveMode game state" do
      set_test_game()

      expect(@resource_manager, :start_up, fn _game_id ->
        :ok
      end)

      result_game = Games.start_live_mode("some-game-id", @resource_manager)

      assert result_game.live_state.state == :in_progress

      unset_test_game()
    end
  end

  describe "end_live_mode/1" do
    test "shuts down ResourceManager and returns a handled EndGameLiveMode game state" do
      set_test_game()

      expect(@resource_manager, :shut_down, fn _game_id ->
        :ok
      end)

      result_game = Games.end_live_mode("some-game-id", @resource_manager)

      assert result_game.live_state.state == :ended

      unset_test_game()
    end
  end

  describe "reset_live_mode/1" do
    test "deletes a game from cache" do
      set_test_game()

      Games.reset_live_mode("some-game-id")

      {:ok, game_json} = Redix.command(:games_cache, ["GET", "some-game-id"])

      assert game_json == nil
    end
  end

  describe "react_to_event/2 for started game" do
    test "when UpdateClockState event is given, returns a game handled by the event" do
      set_test_game()

      event = UpdateClockStateDefinition.create("some-game-id", 10, 1, %{"state" => "running"})
      handled_game = get_test_game() |> UpdateClockStateDefinition.handle(event)

      result_game_state = Games.react_to_event(event, "some-game-id")

      assert result_game_state == handled_game

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

  defp set_go_champs_api_respose(
         away_team_name \\ "Go champs away team",
         home_team_name \\ "Go champs home team"
       ) do
    response_body = %{
      "data" => %{
        "id" => "some-game-id",
        "away_team" => %{
          "name" => away_team_name
        },
        "home_team" => %{
          "name" => home_team_name
        }
      }
    }

    expect(@http_client, :get, fn url, headers ->
      assert url =~ "some-game-id"
      assert headers == [{"Authorization", "Bearer token"}]

      {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
    end)
  end

  defp set_go_champs_view_setting_api_response() do
    response_body = %{
      "data" => nil
    }

    expect(@http_client, :get, fn url ->
      assert url =~ "some-game-id/scoreboard-setting"

      {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
    end)
  end

  defp set_test_game(live_state \\ :not_started) do
    away_team = TeamState.new("Some away team")
    home_team = TeamState.new("Some home team")
    clock_state = GameClockState.new()
    live_state = LiveState.new(live_state)
    game_state = GameState.new("some-game-id", away_team, home_team, clock_state, live_state)
    Redix.command(:games_cache, ["SET", "some-game-id", game_state])
  end

  defp unset_test_game() do
    Redix.command(:games_cache, ["DEL", "some-game-id"])
  end

  defp get_test_game() do
    {:ok, game_json} = Redix.command(:games_cache, ["GET", "some-game-id"])
    GameState.from_json(game_json)
  end
end
