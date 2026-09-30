defmodule GoChampsScoreboard.Games.PlayersTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Players
  alias GoChampsScoreboard.Statistics.Models.Stat
  alias GoChampsScoreboard.Games.Models.PlayerState

  describe "bootstrap" do
    test "returns a new player state with new random id, given name and number" do
      player_state = Players.bootstrap("Michael Jordan", 23)

      assert is_bitstring(player_state.id)
      assert "Michael Jordan" == player_state.name
      assert 23 == player_state.number
    end
  end

  describe "update_manual_stats_values" do
    test "updates the player state with the new value" do
      player_state = %{
        stats_values: %{
          "one-points-made" => 1
        }
      }

      player_stat = Stat.new("one-points-made", :manual, [:increment])

      assert %{
               stats_values: %{
                 "one-points-made" => 2
               }
             } == Players.update_manual_stats_values(player_state, player_stat, "increment")
    end

    test "records a stat missing from a player bootstrapped before the stat existed" do
      player_state = %{
        stats_values: %{
          "fouls_personal" => 1
        }
      }

      player_stat = Stat.new("fouls_disruptive", :manual, [:increment])

      assert %{
               stats_values: %{
                 "fouls_personal" => 1,
                 "fouls_disruptive" => 1
               }
             } == Players.update_manual_stats_values(player_state, player_stat, "increment")
    end

    test "does not update the player state if new value is negative" do
      player_state = %{
        stats_values: %{
          "one-points-made" => 0
        }
      }

      player_stat = Stat.new("one-points-made", :manual, [:decrement])

      assert %{
               stats_values: %{
                 "one-points-made" => 0
               }
             } == Players.update_manual_stats_values(player_state, player_stat, "decrement")
    end
  end

  describe "update_calculated_stats_values" do
    test "updates the player state with the new value" do
      player_state = %{
        stats_values: %{
          "two-points-made" => 5,
          "def-rebounds" => 2,
          "points" => 0,
          "rebounds" => 0
        }
      }

      player_stats = [
        Stat.new(
          "points",
          :calculated,
          [],
          fn player_state -> player_state.stats_values["two-points-made"] * 2 end
        ),
        Stat.new(
          "rebounds",
          :calculated,
          [],
          fn player_state -> player_state.stats_values["def-rebounds"] + 1 end
        )
      ]

      assert %{
               stats_values: %{
                 "two-points-made" => 5,
                 "def-rebounds" => 2,
                 "points" => 10,
                 "rebounds" => 3
               }
             } == Players.update_calculated_stats_values(player_state, player_stats)
    end
  end

  describe "update_state" do
    test "returns player state with update state" do
      player_state = %PlayerState{
        id: "player-id",
        state: :playing
      }

      assert %PlayerState{
               id: "player-id",
               state: :bench
             } == Players.update_state(player_state, :bench)
    end
  end
end
