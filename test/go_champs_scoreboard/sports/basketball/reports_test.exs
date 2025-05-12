defmodule GoChampsScoreboard.Sports.Basketball.ReportsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports

  import GoChampsScoreboard.EventsFixtures

  describe "fetch_report_data/2 fiba-scoresheet" do
    test "returns report data" do
      game_state = game_full_event_log_fixture()

      result = Reports.fetch_report_data("fiba-scoresheet", game_state.id)

      assert result.game_id == game_state.id
      assert result.team_a.name == "Some home team"

      assert result.team_a.players == [
               %FibaScoresheet.Player{
                 id: "123",
                 name: "Home Player 12",
                 number: 12,
                 fouls: []
               }
             ]

      assert Map.get(result.team_a.running_score, 1).type == "FT"
      assert Map.get(result.team_a.running_score, 3).type == "2PT"
      assert Map.get(result.team_a.running_score, 6).type == "3PT"
      assert Map.get(result.team_a.running_score, 9).type == "3PT"
      assert Map.get(result.team_a.running_score, 11).type == "2PT"
      assert Map.get(result.team_a.running_score, 12).type == "FT"
      assert Map.get(result.team_a.running_score, 13).type == "FT"
      assert Map.get(result.team_a.running_score, 15).type == "2PT"
      assert Map.get(result.team_a.running_score, 18).type == "3PT"
      assert Map.get(result.team_a.running_score, 21).type == "3PT"
      assert Map.get(result.team_a.running_score, 23).type == "2PT"
      assert Map.get(result.team_a.running_score, 24).type == "FT"

      assert result.team_b.name == "Some away team"

      assert result.team_b.players == [
               %FibaScoresheet.Player{
                 id: "456",
                 name: "Away Player 22",
                 number: 22,
                 fouls: []
               }
             ]
    end
  end
end
