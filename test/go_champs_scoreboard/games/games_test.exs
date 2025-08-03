defmodule GoChampsScoreboard.Games.GamesTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateClockStateDefinition
  alias GoChampsScoreboard.Games.Games

  alias GoChampsScoreboard.Games.Models.{
    GameState,
    GameClockState,
    LiveState,
    OfficialState,
    TeamState
  }

  import Mox

  setup :verify_on_exit!

  @http_client GoChampsScoreboard.HTTPClientMock
  @resource_manager GoChampsScoreboard.Games.ResourceManagerMock

  describe "find_or_bootstrap/1 when game is set" do
    test "returns game_state" do
      game_state = set_test_game(:in_progress)

      result_game_state = Games.find_or_bootstrap(game_state.id)

      assert result_game_state.id == game_state.id
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Some home team"

      unset_test_game(game_state.id)
    end

    test "returns bootstrapped game from go champs if current game is not_started" do
      game_state = set_test_game()
      # Let's say teams have been updated in Go Champs
      set_go_champs_api_respose(
        game_state.id,
        "Go champs updated away team",
        "Go champs updated home team"
      )

      set_go_champs_view_setting_api_response(game_state.id)

      result_game_state = Games.find_or_bootstrap(game_state.id, "token")

      {:ok, stored_game} = Redix.command(:games_cache, ["GET", "game_state:#{game_state.id}"])

      redis_game = GameState.from_json(stored_game)

      assert redis_game.id == game_state.id
      assert result_game_state.id == game_state.id
      assert result_game_state.away_team.name == "Go champs updated away team"
      assert result_game_state.home_team.name == "Go champs updated home team"

      unset_test_game(game_state.id)
    end

    test "return game from cache and restart resource manager if game is in progress" do
      game_state = set_test_game(:in_progress)

      expect(@resource_manager, :check_and_restart, fn game_id ->
        assert game_id == game_state.id

        :ok
      end)

      result_game_state = Games.find_or_bootstrap(game_state.id, "token", @resource_manager)

      assert result_game_state.id == game_state.id
      assert result_game_state.away_team.name == "Some away team"
      assert result_game_state.home_team.name == "Some home team"

      unset_test_game(game_state.id)
    end
  end

  describe "find_or_bootstrap/1 when game is not set" do
    test "bootstraps game from go champs, store it and returns it" do
      set_go_champs_api_respose()
      set_go_champs_view_setting_api_response()

      result_game_state = Games.find_or_bootstrap("some-game-id", "token")

      {:ok, stored_game} = Redix.command(:games_cache, ["GET", "game_state:some-game-id"])

      redis_game = GameState.from_json(stored_game)

      assert redis_game.id == "some-game-id"
      assert result_game_state.id == "some-game-id"
      assert result_game_state.away_team.name == "Go champs away team"
      assert result_game_state.home_team.name == "Go champs home team"

      unset_test_game("some-game-id")
    end
  end

  describe "start_live_mode/1" do
    test "starts up ResourceManager and returns a handled StartGameLiveMode game state" do
      game_state = set_test_game()

      expect(@resource_manager, :start_up, fn game_id ->
        assert game_id == game_state.id
        :ok
      end)

      result_game = Games.start_live_mode(game_state.id, @resource_manager)

      assert result_game.live_state.state == :in_progress

      unset_test_game(game_state.id)
    end
  end

  describe "end_live_mode/1" do
    test "shuts down ResourceManager and returns a handled EndGameLiveMode game state" do
      game_state = set_test_game()

      expect(@resource_manager, :shut_down, fn game_id ->
        assert game_id == game_state.id
        :ok
      end)

      result_game = Games.end_live_mode(game_state.id, @resource_manager)

      assert result_game.live_state.state == :ended

      unset_test_game(game_state.id)
    end
  end

  describe "react_to_event/2 for started game" do
    test "when UpdateClockState event is given, returns a game handled by the event" do
      game_state = set_test_game()

      event = UpdateClockStateDefinition.create(game_state.id, 10, 1, %{"state" => "running"})
      handled_game = get_test_game(game_state.id) |> UpdateClockStateDefinition.handle(event)

      result_game_state = Games.react_to_event(event, game_state.id)

      assert result_game_state.clock_state.state == handled_game.clock_state.state

      unset_test_game(game_state.id)
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

  describe "add_official/2" do
    test "adds an official to the game state" do
      game_state = %GameState{
        id: "some-game-id",
        away_team: %TeamState{name: "Some away team"},
        home_team: %TeamState{name: "Some home team"},
        officials: []
      }

      official = %OfficialState{id: "some-id", type: :crew_chief, name: "John Doe"}

      result_game_state = Games.add_official(game_state, official)

      assert result_game_state.id == "some-game-id"
      assert length(result_game_state.officials) == 1
      assert result_game_state.officials |> hd() == official
    end
  end

  describe "remove_official/2" do
    test "removes an official from the game state" do
      official = %OfficialState{id: "some-id", type: :crew_chief, name: "John Doe"}

      game_state = %GameState{
        id: "some-game-id",
        away_team: %TeamState{name: "Some away team"},
        home_team: %TeamState{name: "Some home team"},
        officials: [official]
      }

      result_game_state = Games.remove_official(game_state, official.id)

      assert result_game_state.id == "some-game-id"
      assert length(result_game_state.officials) == 0
    end
  end

  describe "update_official/2" do
    test "updates an official in the game state" do
      official = %OfficialState{id: "some-id", type: :crew_chief, name: "John Doe"}

      game_state = %GameState{
        id: "some-game-id",
        away_team: %TeamState{name: "Some away team"},
        home_team: %TeamState{name: "Some home team"},
        officials: [official]
      }

      updated_official = %OfficialState{
        id: "some-id",
        type: :shot_clock_operator,
        name: "Ben John"
      }

      result_game_state = Games.update_official(game_state, updated_official)

      assert result_game_state.id == "some-game-id"
      assert length(result_game_state.officials) == 1
      assert result_game_state.officials |> hd() == updated_official
    end
  end

  defp set_go_champs_api_respose(
         game_id \\ "some-game-id",
         away_team_name \\ "Go champs away team",
         home_team_name \\ "Go champs home team"
       ) do
    response_body = %{
      "data" => %{
        "id" => game_id,
        "away_team" => %{
          "name" => away_team_name
        },
        "home_team" => %{
          "name" => home_team_name
        }
      }
    }

    expect(@http_client, :get, fn url, headers ->
      assert url =~ game_id
      assert headers == [{"Authorization", "Bearer token"}]

      {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
    end)
  end

  defp set_go_champs_view_setting_api_response(game_id \\ "some-game-id") do
    response_body = %{
      "data" => nil
    }

    expect(@http_client, :get, fn url ->
      assert url =~ "#{game_id}/scoreboard-setting"

      {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
    end)
  end

  defp set_test_game(live_state \\ :not_started) do
    away_team = TeamState.new("Some away team")
    home_team = TeamState.new("Some home team")
    clock_state = GameClockState.new()
    live_state = LiveState.new(live_state)

    game_state =
      GameState.new(Ecto.UUID.generate(), away_team, home_team, clock_state, live_state)

    Redix.command(:games_cache, ["SET", "game_state:#{game_state.id}", game_state])

    game_state
  end

  defp unset_test_game(game_id) do
    Redix.command(:games_cache, ["DEL", "game_state:#{game_id}"])
  end

  defp get_test_game(game_id) do
    {:ok, game_json} = Redix.command(:games_cache, ["GET", "game_state:#{game_id}"])
    GameState.from_json(game_json)
  end
end
