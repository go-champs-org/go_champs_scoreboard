defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManagerTest do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.Team
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.Player
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager

  use ExUnit.Case

  describe "find_player/2" do
    test "returns the player with the given ID from a given team" do
      player = %Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: []
      }

      team = %Team{
        players: [player]
      }

      result = PlayerManager.find_player(team, "123")

      assert result == player
    end
  end

  describe "set_as_starter/1" do
    test "marks the player as having started and played, and sets first played period" do
      player = %Player{
        id: "123",
        name: "Player 1",
        number: 12,
        fouls: [],
        has_played: false,
        has_started: false,
        first_played_period: nil
      }

      updated_player = PlayerManager.set_as_starter(player)

      assert updated_player.has_played == true
      assert updated_player.has_started == true
      assert updated_player.first_played_period == 1
    end
  end
end
