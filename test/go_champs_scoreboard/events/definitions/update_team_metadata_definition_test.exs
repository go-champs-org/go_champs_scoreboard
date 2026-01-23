defmodule GoChampsScoreboard.Events.Definitions.UpdateTeamMetadataDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateTeamMetadataDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.TeamState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{
        home_team: TeamState.new("Home Team"),
        away_team: TeamState.new("Away Team")
      }

      payload = %{
        "team-type" => "home",
        "name" => "Updated Home Team"
      }

      assert {:ok} = UpdateTeamMetadataDefinition.validate(game_state, payload)
    end
  end

  describe "create/4" do
    test "returns event" do
      assert %Event{
               key: "update-team-metadata",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdateTeamMetadataDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "name" => "Updated Team Name"
               })
    end
  end

  describe "handle/2" do
    @initial_state %GameState{
      home_team: %TeamState{
        name: "Original Home Team",
        tri_code: "HOM",
        primary_color: "#FF0000",
        players: [],
        coaches: [],
        total_player_stats: %{},
        total_coach_stats: %{},
        stats_values: %{},
        logo_url: "",
        period_stats: %{}
      },
      away_team: %TeamState{
        name: "Original Away Team",
        tri_code: "AWY",
        primary_color: "#0000FF",
        players: [],
        coaches: [],
        total_player_stats: %{},
        total_coach_stats: %{},
        stats_values: %{},
        logo_url: "",
        period_stats: %{}
      },
      sport_id: "basketball"
    }

    test "updates team name for home team" do
      payload = %{
        "team-type" => "home",
        "name" => "New Home Team Name"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.home_team.name == "New Home Team Name"
      assert result.home_team.tri_code == "HOM"
      assert result.home_team.primary_color == "#FF0000"
      # Verify away team unchanged
      assert result.away_team.name == "Original Away Team"
      assert result != @initial_state
    end

    test "updates tri_code for away team" do
      payload = %{
        "team-type" => "away",
        "tri_code" => "NEW"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.away_team.tri_code == "NEW"
      assert result.away_team.name == "Original Away Team"
      assert result.away_team.primary_color == "#0000FF"
      # Verify home team unchanged
      assert result.home_team.name == "Original Home Team"
      assert result != @initial_state
    end

    test "updates primary_color for home team" do
      payload = %{
        "team-type" => "home",
        "primary_color" => "#00FF00"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.home_team.primary_color == "#00FF00"
      assert result.home_team.name == "Original Home Team"
      assert result.home_team.tri_code == "HOM"
      assert result != @initial_state
    end

    test "updates multiple fields at once for home team" do
      payload = %{
        "team-type" => "home",
        "name" => "Completely New Team",
        "tri_code" => "CNT",
        "primary_color" => "#FFFF00"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.home_team.name == "Completely New Team"
      assert result.home_team.tri_code == "CNT"
      assert result.home_team.primary_color == "#FFFF00"
      # Verify away team unchanged
      assert result.away_team.name == "Original Away Team"
      assert result.away_team.tri_code == "AWY"
      assert result.away_team.primary_color == "#0000FF"
      assert result != @initial_state
    end

    test "updates multiple fields at once for away team" do
      payload = %{
        "team-type" => "away",
        "name" => "New Away Team",
        "tri_code" => "NAT",
        "primary_color" => "#FF00FF"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.away_team.name == "New Away Team"
      assert result.away_team.tri_code == "NAT"
      assert result.away_team.primary_color == "#FF00FF"
      # Verify home team unchanged
      assert result.home_team.name == "Original Home Team"
      assert result.home_team.tri_code == "HOM"
      assert result.home_team.primary_color == "#FF0000"
      assert result != @initial_state
    end

    test "ignores nil values" do
      payload = %{
        "team-type" => "home",
        "name" => "New Name",
        "tri_code" => nil,
        "primary_color" => nil
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.home_team.name == "New Name"
      # unchanged
      assert result.home_team.tri_code == "HOM"
      # unchanged
      assert result.home_team.primary_color == "#FF0000"
      assert result != @initial_state
    end

    test "ignores missing fields" do
      payload = %{
        "team-type" => "home",
        "name" => "Only Name Updated"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.home_team.name == "Only Name Updated"
      # unchanged
      assert result.home_team.tri_code == "HOM"
      # unchanged
      assert result.home_team.primary_color == "#FF0000"
      assert result != @initial_state
    end

    test "handles empty string values" do
      payload = %{
        "team-type" => "away",
        "primary_color" => ""
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(@initial_state, event)

      assert result.away_team.primary_color == ""
      assert result.away_team.name == "Original Away Team"
      assert result.away_team.tri_code == "AWY"
      assert result != @initial_state
    end

    test "preserves other team state fields" do
      initial_with_players = %{
        @initial_state
        | home_team: %{
            @initial_state.home_team
            | players: [
                %{id: "player-1", name: "Player One"},
                %{id: "player-2", name: "Player Two"}
              ],
              stats_values: %{"points" => 50, "rebounds" => 30}
          }
      }

      payload = %{
        "team-type" => "home",
        "name" => "Updated Team Name"
      }

      event = UpdateTeamMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateTeamMetadataDefinition.handle(initial_with_players, event)

      assert result.home_team.name == "Updated Team Name"
      # Verify other fields are preserved
      assert length(result.home_team.players) == 2
      assert result.home_team.stats_values == %{"points" => 50, "rebounds" => 30}
      assert result != initial_with_players
    end
  end

  describe "key/0" do
    test "returns the correct event key" do
      assert UpdateTeamMetadataDefinition.key() == "update-team-metadata"
    end
  end

  describe "stream_config/0" do
    test "returns default stream config" do
      config = UpdateTeamMetadataDefinition.stream_config()
      assert %GoChampsScoreboard.Events.Models.StreamConfig{} = config
    end
  end
end
