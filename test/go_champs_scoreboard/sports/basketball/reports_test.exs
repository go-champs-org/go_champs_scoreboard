defmodule GoChampsScoreboard.Sports.Basketball.ReportsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Sports.Basketball.Reports

  import GoChampsScoreboard.EventsFixtures

  describe "fetch_report_data/2 fiba-boxscore" do
    test "returns report data" do
      game_state = game_full_event_log_fixture()

      result = Reports.fetch_report_data("fiba-boxscore", game_state.id)
      assert result.number == game_state.info.number
      assert result.location == game_state.info.location
      assert result.datetime == game_state.info.datetime
      assert result.tournament_name == game_state.info.tournament_name
      assert result.organization_name == game_state.info.organization_name
      assert result.organization_logo_url == game_state.info.organization_logo_url
      assert result.web_url == game_state.info.web_url
      # Assert home_team fields
      home_team = result.home_team
      assert home_team.name == "Some home team"
      assert home_team.points_by_period == %{"4" => 0}
      assert home_team.total_points == 0
      assert home_team.total_player_stats["field_goals_made"] == 0

      assert [
               %FibaBoxScore.Player{
                 id: "123",
                 name: "Home Player 12",
                 number: 12,
                 stats_values: player_stats
               }
             ] = home_team.players

      assert player_stats["field_goals_made"] == 0
      assert player_stats["free_throws_made"] == 1
      assert player_stats["three_point_field_goals_made"] == 0
      # Assert away_team fields
      away_team = result.away_team
      assert away_team.name == "Some away team"
      assert away_team.points_by_period == %{}
      assert away_team.total_points == 0
      assert away_team.total_player_stats["field_goals_made"] == 0
      assert away_team.total_player_stats["free_throws_made"] == 0
      assert away_team.total_player_stats["three_point_field_goals_made"] == 0

      assert [
               %FibaBoxScore.Player{
                 id: "456",
                 name: "Away Player 22",
                 number: 22,
                 stats_values: away_player_stats
               }
             ] = away_team.players

      assert away_player_stats["field_goals_made"] == 0
      assert away_player_stats["free_throws_made"] == 0
      assert away_player_stats["three_point_field_goals_made"] == 0
    end
  end

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
                 fouls: [],
                 is_captain: false
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
                 fouls: [],
                 is_captain: false
               }
             ]
    end
  end
end
