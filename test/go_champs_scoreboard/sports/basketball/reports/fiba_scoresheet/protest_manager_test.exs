defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.ProtestManagerTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.ProtestManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.ProtestState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.PlayerState

  describe "bootstrap/1" do
    test "initializes a new protest with no_protest state when game has no protest" do
      game_state = %GameState{
        protest: ProtestState.new(:none, "", :no_protest)
      }

      protest = ProtestManager.bootstrap(game_state)

      assert %FibaScoresheet.Protest{} = protest
      assert protest.state == :no_protest
      assert protest.player_name == ""
    end

    test "initializes protest with player name when game has protest_filed for home team" do
      player = %PlayerState{
        id: "home-player-123",
        name: "Home Player Name"
      }

      home_team = %TeamState{
        name: "Home Team",
        players: [player]
      }

      game_state = %GameState{
        home_team: home_team,
        away_team: %TeamState{name: "Away Team", players: []},
        protest: ProtestState.new(:home, "home-player-123", :protest_filed)
      }

      protest = ProtestManager.bootstrap(game_state)

      assert %FibaScoresheet.Protest{} = protest
      assert protest.state == :protest_filed
      assert protest.player_name == "Home Player Name"
    end

    test "initializes protest with player name and signature when game has protest_filed for away team" do
      player = %PlayerState{
        id: "away-player-456",
        name: "Away Player Name",
        signature: "some-signature-data"
      }

      away_team = %TeamState{
        name: "Away Team",
        players: [player]
      }

      game_state = %GameState{
        home_team: %TeamState{name: "Home Team", players: []},
        away_team: away_team,
        protest: ProtestState.new(:away, "away-player-456", :protest_filed)
      }

      protest = ProtestManager.bootstrap(game_state)

      assert %FibaScoresheet.Protest{} = protest
      assert protest.state == :protest_filed
      assert protest.player_name == "Away Player Name"
      assert protest.signature == "some-signature-data"
    end

    test "returns empty player name and signature when protest_filed but player not found" do
      game_state = %GameState{
        home_team: %TeamState{name: "Home Team", players: []},
        away_team: %TeamState{name: "Away Team", players: []},
        protest: ProtestState.new(:home, "non-existent-player", :protest_filed)
      }

      protest = ProtestManager.bootstrap(game_state)

      assert %FibaScoresheet.Protest{} = protest
      assert protest.state == :protest_filed
      assert protest.player_name == ""
      assert protest.signature == nil
    end

    test "handles nil protest state gracefully" do
      game_state = %GameState{
        protest: nil
      }

      protest = ProtestManager.bootstrap(game_state)

      assert %FibaScoresheet.Protest{} = protest
      assert protest.state == :no_protest
      assert protest.player_name == ""
    end
  end
end
