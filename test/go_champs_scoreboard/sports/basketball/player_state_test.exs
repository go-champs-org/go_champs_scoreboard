defmodule GoChampsScoreboard.Sports.Basketball.PlayerStateTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Basketball.PlayerState

  describe "update_player_state/1" do
    test "returns the same player when called" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "test-player-1",
        stats_values: %{
          "fouls" => 2,
          "field_goals_made" => 5,
          "points" => 10
        }
      }

      result = PlayerState.update_player_state(player)

      assert result == player
      assert result.id == "test-player-1"
      assert result.stats_values["fouls"] == 2
      assert result.stats_values["field_goals_made"] == 5
      assert result.stats_values["points"] == 10
    end

    test "handles player with empty stats" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "empty-stats-player",
        stats_values: %{}
      }

      result = PlayerState.update_player_state(player)

      assert result == player
      assert result.id == "empty-stats-player"
      assert result.stats_values == %{}
    end

    test "handles player with high foul count" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "high-fouls-player",
        state: :playing,
        stats_values: %{"fouls" => 5}
      }

      result = PlayerState.update_player_state(player)

      # Player should be disqualified when fouls >= 5
      assert result.stats_values["fouls"] == 5
      assert result.state == :disqualified
    end

    test "does not change state when player has less than 5 fouls" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "low-fouls-player",
        state: :playing,
        stats_values: %{"fouls" => 3}
      }

      result = PlayerState.update_player_state(player)

      # Player should remain in current state when fouls < 5
      assert result.stats_values["fouls"] == 3
      assert result.state == :playing
    end

    test "does not change state when player is already disqualified" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "already-disqualified-player",
        state: :disqualified,
        stats_values: %{"fouls" => 6}
      }

      result = PlayerState.update_player_state(player)

      # Player should remain disqualified (no state change)
      assert result.stats_values["fouls"] == 6
      assert result.state == :disqualified
    end

    test "disqualifies player exactly at 5 fouls" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "five-fouls-player",
        state: :bench,
        stats_values: %{"fouls" => 5}
      }

      result = PlayerState.update_player_state(player)

      # Player should be disqualified at exactly 5 fouls
      assert result.stats_values["fouls"] == 5
      assert result.state == :disqualified
    end

    test "disqualifies player with 1 game disqualifying foul" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "game-disqualifying-player",
        state: :playing,
        stats_values: %{
          "fouls" => 2,
          "fouls_game_disqualifying" => 1
        }
      }

      result = PlayerState.update_player_state(player)

      # Player should be disqualified with 1 game disqualifying foul
      assert result.stats_values["fouls"] == 2
      assert result.stats_values["fouls_game_disqualifying"] == 1
      assert result.state == :disqualified
    end

    test "does not disqualify player with 0 game disqualifying fouls and less than 5 regular fouls" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "safe-player",
        state: :playing,
        stats_values: %{
          "fouls" => 3,
          "fouls_game_disqualifying" => 0
        }
      }

      result = PlayerState.update_player_state(player)

      # Player should remain in current state
      assert result.stats_values["fouls"] == 3
      assert result.stats_values["fouls_game_disqualifying"] == 0
      assert result.state == :playing
    end

    test "disqualifies player with game disqualifying foul even if already disqualified" do
      player = %GoChampsScoreboard.Games.Models.PlayerState{
        id: "already-disqualified-with-game-foul",
        state: :disqualified,
        stats_values: %{
          "fouls" => 6,
          "fouls_game_disqualifying" => 1
        }
      }

      result = PlayerState.update_player_state(player)

      # Player should remain disqualified (no state change)
      assert result.stats_values["fouls"] == 6
      assert result.stats_values["fouls_game_disqualifying"] == 1
      assert result.state == :disqualified
    end
  end
end
