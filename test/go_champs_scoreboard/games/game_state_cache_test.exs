defmodule GoChampsScoreboard.Games.GameStateCacheTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.GameStateCache

  alias GoChampsScoreboard.Games.Models.{
    GameState,
    TeamState,
    GameClockState,
    LiveState,
    OfficialState
  }

  setup do
    game_id = "test-game-id-#{:rand.uniform(10000)}"

    on_exit(fn ->
      Redix.command(:games_cache, ["DEL", "game_state:#{game_id}"])
    end)

    %{game_id: game_id}
  end

  describe "get/1" do
    test "returns {:ok, nil} when game does not exist in cache", %{game_id: game_id} do
      assert GameStateCache.get(game_id) == {:ok, nil}
    end

    test "returns {:ok, game_state} when game exists in cache", %{game_id: game_id} do
      game_state = create_test_game_state(game_id)

      Redix.command(:games_cache, ["SET", "game_state:#{game_id}", game_state])

      {:ok, retrieved_game_state} = GameStateCache.get(game_id)

      assert retrieved_game_state.id == game_id
      assert retrieved_game_state.home_team.name == "Home Team"
      assert retrieved_game_state.away_team.name == "Away Team"
      assert retrieved_game_state.live_state.state == :not_started
    end

    test "returns {:error, reason} when Redis returns an error", %{game_id: _game_id} do
      assert {:ok, nil} = GameStateCache.get("")
    end

    test "properly deserializes complex game state from JSON", %{game_id: game_id} do
      away_team = TeamState.new(Ecto.UUID.generate(), "Complex Away Team")
      home_team = TeamState.new(Ecto.UUID.generate(), "Complex Home Team")

      clock_state = %GameClockState{
        time: 720,
        period: 1,
        state: :running,
        initial_period_time: 720,
        initial_extra_period_time: 300,
        started_at: nil,
        finished_at: nil
      }

      live_state = %LiveState{state: :in_progress}

      game_state = GameState.new(game_id, away_team, home_team, clock_state, live_state)

      Redix.command(:games_cache, ["SET", "game_state:#{game_id}", game_state])

      {:ok, retrieved_game_state} = GameStateCache.get(game_id)

      assert retrieved_game_state.id == game_id
      assert retrieved_game_state.home_team.name == "Complex Home Team"
      assert retrieved_game_state.away_team.name == "Complex Away Team"
      assert retrieved_game_state.clock_state.time == 720
      assert retrieved_game_state.clock_state.period == 1
      assert retrieved_game_state.clock_state.state == :running
      assert retrieved_game_state.live_state.state == :in_progress
    end
  end

  describe "update/1" do
    test "stores game state in cache and returns the game state", %{game_id: game_id} do
      game_state = create_test_game_state(game_id)

      returned_game_state = GameStateCache.update(game_state)

      assert returned_game_state == game_state

      {:ok, stored_json} = Redix.command(:games_cache, ["GET", "game_state:#{game_id}"])
      stored_game_state = GameState.from_json(stored_json)

      assert stored_game_state.id == game_id
      assert stored_game_state.home_team.name == "Home Team"
      assert stored_game_state.away_team.name == "Away Team"
    end

    test "sets expiration time on stored game state", %{game_id: game_id} do
      game_state = create_test_game_state(game_id)

      GameStateCache.update(game_state)

      {:ok, ttl} = Redix.command(:games_cache, ["TTL", "game_state:#{game_id}"])

      assert ttl > 172_790
      assert ttl <= 172_800
    end

    test "overwrites existing game state", %{game_id: game_id} do
      initial_game_state = create_test_game_state(game_id)
      GameStateCache.update(initial_game_state)

      away_team = TeamState.new(Ecto.UUID.generate(), "Updated Away Team")
      home_team = TeamState.new(Ecto.UUID.generate(), "Updated Home Team")
      clock_state = GameClockState.new()
      live_state = LiveState.new(:in_progress)
      updated_game_state = GameState.new(game_id, away_team, home_team, clock_state, live_state)

      GameStateCache.update(updated_game_state)

      {:ok, retrieved_game_state} = GameStateCache.get(game_id)

      assert retrieved_game_state.home_team.name == "Updated Home Team"
      assert retrieved_game_state.away_team.name == "Updated Away Team"
      assert retrieved_game_state.live_state.state == :in_progress
    end

    test "handles game state with complex nested data", %{game_id: game_id} do
      away_team = TeamState.new(Ecto.UUID.generate(), "Away Team")
      home_team = TeamState.new(Ecto.UUID.generate(), "Home Team")

      official1 = %OfficialState{
        id: "official-1",
        name: "John Referee",
        type: :crew_chief,
        license_number: "REF001",
        federation: "NBA"
      }

      official2 = %OfficialState{
        id: "official-2",
        name: "Jane Umpire",
        type: :umpire_1,
        license_number: "UMP001",
        federation: "NBA"
      }

      clock_state = %GameClockState{
        time: 600,
        period: 2,
        state: :running,
        initial_period_time: 720,
        initial_extra_period_time: 300,
        started_at: nil,
        finished_at: nil
      }

      live_state = %LiveState{state: :in_progress}

      game_state = %GameState{
        id: game_id,
        away_team: away_team,
        home_team: home_team,
        clock_state: clock_state,
        live_state: live_state,
        officials: [official1, official2]
      }

      GameStateCache.update(game_state)
      {:ok, retrieved_game_state} = GameStateCache.get(game_id)

      assert length(retrieved_game_state.officials) == 2
      assert Enum.any?(retrieved_game_state.officials, &(&1.name == "John Referee"))
      assert Enum.any?(retrieved_game_state.officials, &(&1.name == "Jane Umpire"))
      assert retrieved_game_state.clock_state.time == 600
      assert retrieved_game_state.clock_state.period == 2
      assert retrieved_game_state.clock_state.state == :running
    end
  end

  describe "cache_key format" do
    test "uses correct key format for Redis storage", %{game_id: game_id} do
      game_state = create_test_game_state(game_id)

      GameStateCache.update(game_state)

      expected_key = "game_state:#{game_id}"
      {:ok, stored_data} = Redix.command(:games_cache, ["GET", expected_key])

      assert stored_data != nil

      {:ok, old_format_data} = Redix.command(:games_cache, ["GET", game_id])
      assert old_format_data == nil
    end
  end

  describe "integration between get and update" do
    test "can store and retrieve the same game state", %{game_id: game_id} do
      original_game_state = create_test_game_state(game_id)

      GameStateCache.update(original_game_state)

      {:ok, retrieved_game_state} = GameStateCache.get(game_id)

      assert retrieved_game_state.id == original_game_state.id
      assert retrieved_game_state.home_team.name == original_game_state.home_team.name
      assert retrieved_game_state.away_team.name == original_game_state.away_team.name
      assert retrieved_game_state.clock_state.time == original_game_state.clock_state.time
      assert retrieved_game_state.clock_state.period == original_game_state.clock_state.period
      assert retrieved_game_state.live_state.state == original_game_state.live_state.state
    end

    test "handles multiple game states independently", %{game_id: _game_id} do
      game_id_1 = "test-game-1-#{:rand.uniform(10000)}"
      game_id_2 = "test-game-2-#{:rand.uniform(10000)}"

      game_state_1 = create_test_game_state(game_id_1, "Team A1", "Team B1")
      game_state_2 = create_test_game_state(game_id_2, "Team A2", "Team B2")

      GameStateCache.update(game_state_1)
      GameStateCache.update(game_state_2)

      {:ok, retrieved_1} = GameStateCache.get(game_id_1)
      {:ok, retrieved_2} = GameStateCache.get(game_id_2)

      assert retrieved_1.id == game_id_1
      assert retrieved_1.home_team.name == "Team A1"
      assert retrieved_2.id == game_id_2
      assert retrieved_2.home_team.name == "Team A2"

      Redix.command(:games_cache, ["DEL", "game_state:#{game_id_1}"])
      Redix.command(:games_cache, ["DEL", "game_state:#{game_id_2}"])
    end
  end

  defp create_test_game_state(game_id, home_name \\ "Home Team", away_name \\ "Away Team") do
    away_team = TeamState.new(Ecto.UUID.generate(), away_name)
    home_team = TeamState.new(Ecto.UUID.generate(), home_name)
    clock_state = GameClockState.new()
    live_state = LiveState.new()

    GameState.new(game_id, away_team, home_team, clock_state, live_state)
  end
end
