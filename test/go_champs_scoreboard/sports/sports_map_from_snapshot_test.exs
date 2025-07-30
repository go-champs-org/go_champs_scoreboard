defmodule GoChampsScoreboard.Sports.SportsMapFromSnapshotTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Sports
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Events.GameSnapshot

  import GoChampsScoreboard.GameStateFixtures

  describe "map_from_snapshot/3" do
    test "delegates to Basketball.GameState.map_from_snapshot for basketball sport" do
      original_game_state = basketball_game_state_fixture()

      # Create a different game state that would be in the snapshot
      snapshot_game_state = %GameState{
        original_game_state
        | clock_state: %GameClockState{
            original_game_state.clock_state
            | time: 300,
              period: 2,
              state: :running
          }
      }

      # Create a mock snapshot structure
      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = Sports.map_from_snapshot("basketball", original_game_state, mock_snapshot)

      assert result.clock_state.time == 300
      assert result.clock_state.period == 2
      assert result.clock_state.state == :running
      assert result.id == snapshot_game_state.id
    end

    test "returns game state from snapshot when snapshot contains a valid GameState for non-basketball sport" do
      original_game_state = game_state_fixture()

      # Create a different game state that would be in the snapshot
      snapshot_game_state = %GameState{
        original_game_state
        | clock_state: %GameClockState{
            original_game_state.clock_state
            | time: 300,
              period: 2,
              state: :running
          }
      }

      # Create a mock snapshot structure
      mock_snapshot = %GameSnapshot{state: snapshot_game_state}

      result = Sports.map_from_snapshot("soccer", original_game_state, mock_snapshot)

      assert result.clock_state.time == 300
      assert result.clock_state.period == 2
      assert result.clock_state.state == :running
      assert result.id == original_game_state.id
    end

    test "returns original game state when snapshot state is not a valid GameState" do
      original_game_state = game_state_fixture()

      # Create a mock snapshot with invalid state
      mock_snapshot = %GameSnapshot{state: %{invalid: "data"}}

      result = Sports.map_from_snapshot("soccer", original_game_state, mock_snapshot)

      assert result == original_game_state
    end

    test "returns original game state when snapshot state is nil" do
      original_game_state = game_state_fixture()

      # Create a mock snapshot with nil state
      mock_snapshot = %GameSnapshot{state: nil}

      result = Sports.map_from_snapshot("soccer", original_game_state, mock_snapshot)

      assert result == original_game_state
    end
  end
end
