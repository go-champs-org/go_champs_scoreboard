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
end
