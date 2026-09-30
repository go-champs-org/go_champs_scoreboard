defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.UpdatePlayerStatProcessorTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.UpdatePlayerStatProcessor

  defp box_score do
    player = %FibaBoxScore.Player{id: "123", name: "Player 1", number: 12, stats_values: %{}}

    %FibaBoxScore{
      home_team: %FibaBoxScore.Team{name: "Home", players: [player], points_by_period: %{}},
      away_team: %FibaBoxScore.Team{name: "Away", players: [], points_by_period: %{}}
    }
  end

  defp increment(data, stat_id) do
    event_log = %EventLog{
      key: "update-player-stat",
      game_clock_period: 1,
      payload: %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "123",
        "stat-id" => stat_id
      }
    }

    UpdatePlayerStatProcessor.process(event_log, data)
  end

  describe "process/2" do
    test "counts the FIBA 2026 fouls in the player fouls" do
      result =
        box_score()
        |> increment("fouls_technical_category_1")
        |> increment("fouls_disruptive")
        |> increment("fouls_flagrant")

      [player] = result.home_team.players

      assert player.stats_values["fouls_technical_category_1"] == 1
      assert player.stats_values["fouls_disruptive"] == 1
      assert player.stats_values["fouls_flagrant"] == 1
      assert player.stats_values["fouls"] == 3
    end
  end
end
