defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns a fiba scoresheet data running score when event log payload with free_throws_made operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "free_throws_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_running_score = %{
        1 => %FibaScoresheet.PointScore{
          type: "FT",
          player_number: 12,
          period: game_state.clock_state.period,
          is_last_of_period: false
        }
      }

      assert result_scoresheet.team_a.running_score == expected_running_score
      assert result_scoresheet.team_a.score == 1
    end

    test "returns a fiba scoresheet data running score when event log payload with field_goals_made operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "field_goals_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_running_score = %{
        2 => %FibaScoresheet.PointScore{
          type: "2PT",
          player_number: 23,
          period: game_state.clock_state.period,
          is_last_of_period: false
        }
      }

      assert result_scoresheet.team_b.running_score == expected_running_score
      assert result_scoresheet.team_b.score == 2
    end

    test "returns a fiba scoresheet data running score when event log payload with three_point_field_goals_made operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "three_point_field_goals_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_running_score = %{
        3 => %FibaScoresheet.PointScore{
          type: "3PT",
          player_number: 23,
          period: game_state.clock_state.period,
          is_last_of_period: false
        }
      }

      assert result_scoresheet.team_b.running_score == expected_running_score
      assert result_scoresheet.team_b.score == 3
    end

    test "returns a fiba scoresheet data player fouls when event log payload with fouls_personal operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "fouls_personal"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "P",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_b.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_b.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data player fouls when event log payload with fouls_technical operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "T",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_a.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data player fouls with extra_action when event log payload with fouls_personal operation is increment, team-type is away, and metadata has free-throws-awarded" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "fouls_personal",
            "metadata" => %{
              "free-throws-awarded" => "3"
            }
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "P",
          extra_action: "3",
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_b.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_b.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data player fouls when event log payload with fouls_unsportsmanlike operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_unsportsmanlike"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "U",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_a.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data player fouls when event log payload with fouls_disqualifying operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "fouls_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "D",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_b.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_b.all_fouls == expected_fouls
    end

    test "returns a fiba scoresheet data player fouls when event log payload with fouls_game_disqualifying operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_game_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "GD",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_a.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns a fiba scoresheet data player fouls when event log payload with fouls_disqualifying_fighting operation is increment and team-type is home" do
      event_log = %GoChampsScoreboard.Events.EventLog{
        key: "update-player-stat",
        game_id: "test-game-id",
        timestamp: DateTime.utc_now(),
        game_clock_period: 2,
        game_clock_time: 480,
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "fouls_disqualifying_fighting"
        },
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        }
      ]

      [player] = result_scoresheet.team_a.players

      assert player.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns unchanged fiba scoresheet when event log payload has non-scoring/non-foul stat-id" do
      event_log = %GoChampsScoreboard.Events.EventLog{
        key: "update-player-stat",
        game_id: "test-game-id",
        timestamp: DateTime.utc_now(),
        game_clock_period: 1,
        game_clock_time: 600,
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "123",
          "stat-id" => "rebounds"
        },
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      original_fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, original_fiba_scoresheet)

      # Should be unchanged since it's not a scoring or foul stat
      assert result_scoresheet == original_fiba_scoresheet
    end

    test "skips processing when player-id does not exist in scoresheet for scoring stats" do
      game_state = basketball_game_state_fixture()

      # Use the first player from the game state
      existing_player_in_game = List.first(game_state.home_team.players)

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => existing_player_in_game.id,
            "stat-id" => "free_throws_made"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Create scoresheet with different player ID (not the one from event)
      team_a_players = [
        %FibaScoresheet.Player{id: "different-player-id", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      # Should be unchanged since player was not found in scoresheet
      assert result_scoresheet == fiba_scoresheet
      assert result_scoresheet.team_a.running_score == %{}
      assert result_scoresheet.team_a.score == 0
    end

    test "skips processing when player-id does not exist in scoresheet for foul stats" do
      game_state = basketball_game_state_fixture()

      # Use the first player from the game state
      existing_player_in_game = List.first(game_state.home_team.players)

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => existing_player_in_game.id,
            "stat-id" => "fouls_personal"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Create scoresheet with different player ID (not the one from event)
      team_a_players = [
        %FibaScoresheet.Player{id: "different-player-id", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      # Should be unchanged since player was not found in scoresheet
      assert result_scoresheet == fiba_scoresheet

      # Verify no fouls were added to any player
      existing_player =
        Enum.find(result_scoresheet.team_a.players, fn p -> p.id == "different-player-id" end)

      assert existing_player.fouls == []
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "automatically adds GD foul when player receives second T foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has one T foul
      existing_t_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: [existing_t_foul]}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_a.players

      # Should have 3 fouls: original T + new T + automatic GD
      assert length(player.fouls) == 3

      # Check that we have 2 T fouls and 1 GD foul
      t_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "T" end)
      gd_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "GD" end)

      assert length(t_fouls) == 2
      assert length(gd_fouls) == 1

      # GD foul should be in the same period as the triggering T foul
      gd_foul = List.first(gd_fouls)
      assert gd_foul.period == game_state.clock_state.period
    end

    test "automatically adds GD foul when player receives second U foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "fouls_unsportsmanlike"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has one U foul
      existing_u_foul = %FibaScoresheet.Foul{
        type: "U",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: [existing_u_foul]}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_b.players

      # Should have 3 fouls: original U + new U + automatic GD
      assert length(player.fouls) == 3

      # Check that we have 2 U fouls and 1 GD foul
      u_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "U" end)
      gd_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "GD" end)

      assert length(u_fouls) == 2
      assert length(gd_fouls) == 1

      # GD foul should be in the same period as the triggering U foul
      gd_foul = List.first(gd_fouls)
      assert gd_foul.period == game_state.clock_state.period
    end

    test "automatically adds GD foul when player receives U foul after already having T foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_unsportsmanlike"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has one T foul
      existing_t_foul = %FibaScoresheet.Foul{
        type: "T",
        period: 1,
        extra_action: nil,
        is_last_of_half: false
      }

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: [existing_t_foul]}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_a.players

      # Should have 3 fouls: original T + new U + automatic GD
      assert length(player.fouls) == 3

      # Check that we have 1 T, 1 U, and 1 GD foul
      t_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "T" end)
      u_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "U" end)
      gd_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "GD" end)

      assert length(t_fouls) == 1
      assert length(u_fouls) == 1
      assert length(gd_fouls) == 1

      # GD foul should be in the same period as the triggering U foul
      gd_foul = List.first(gd_fouls)
      assert gd_foul.period == game_state.clock_state.period
    end

    test "automatically adds GD foul when player receives T foul after already having U foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has one U foul
      existing_u_foul = %FibaScoresheet.Foul{
        type: "U",
        period: 2,
        extra_action: nil,
        is_last_of_half: false
      }

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: [existing_u_foul]}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_b.players

      # Should have 3 fouls: original U + new T + automatic GD
      assert length(player.fouls) == 3

      # Check that we have 1 T, 1 U, and 1 GD foul
      t_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "T" end)
      u_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "U" end)
      gd_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "GD" end)

      assert length(t_fouls) == 1
      assert length(u_fouls) == 1
      assert length(gd_fouls) == 1

      # GD foul should be in the same period as the triggering T foul
      gd_foul = List.first(gd_fouls)
      assert gd_foul.period == game_state.clock_state.period
    end

    test "does not add GD foul when player has only one T foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: []}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_a.players

      # Should have only 1 foul (the T foul), no automatic GD
      assert length(player.fouls) == 1
      assert List.first(player.fouls).type == "T"
    end

    test "does not add GD foul when adding P foul regardless of existing T/U fouls" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_personal"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has T and U fouls, but adding P shouldn't trigger GD
      existing_fouls = [
        %FibaScoresheet.Foul{type: "T", period: 1, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "U", period: 2, extra_action: nil, is_last_of_half: false}
      ]

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: existing_fouls}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_a.players

      # Should have 3 fouls: T + U + new P (no automatic GD because P foul was added)
      assert length(player.fouls) == 3

      foul_types = Enum.map(player.fouls, fn foul -> foul.type end)
      assert "T" in foul_types
      assert "U" in foul_types
      assert "P" in foul_types
      refute "GD" in foul_types
    end

    test "adds additional F fouls until player reaches 5 total when receiving F foul with less than 5 fouls" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has 2 fouls
      existing_fouls = [
        %FibaScoresheet.Foul{type: "P", period: 1, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "P", period: 2, extra_action: nil, is_last_of_half: false}
      ]

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: existing_fouls}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_a.players

      # Should have 5 fouls total: 2 existing P + 1 F + 2 additional F
      assert length(player.fouls) == 5

      # Count F fouls - should have 3 F fouls total
      f_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "F" end)
      assert length(f_fouls) == 3

      # All F fouls should be in the same period
      f_periods = Enum.map(f_fouls, fn foul -> foul.period end)
      assert Enum.all?(f_periods, fn period -> period == game_state.clock_state.period end)
    end

    test "does not add additional F fouls when player already has 5+ fouls" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "player-id" => "456",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player already has 5 fouls
      existing_fouls = [
        %FibaScoresheet.Foul{type: "P", period: 1, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "P", period: 2, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "P", period: 3, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "P", period: 4, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "T", period: 4, extra_action: nil, is_last_of_half: false}
      ]

      team_b_players = [
        %FibaScoresheet.Player{id: "456", name: "Player 2", number: 23, fouls: existing_fouls}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_players: team_b_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_b.players

      # Should have 6 fouls total: 5 existing + 1 F (no additional F fouls)
      assert length(player.fouls) == 6

      # Should have only 1 F foul
      f_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "F" end)
      assert length(f_fouls) == 1
    end

    test "adds F fouls to reach exactly 5 when player has 1 existing foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "player-id" => "123",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player has only 1 existing foul
      existing_fouls = [
        %FibaScoresheet.Foul{type: "P", period: 1, extra_action: nil, is_last_of_half: false}
      ]

      team_a_players = [
        %FibaScoresheet.Player{id: "123", name: "Player 1", number: 12, fouls: existing_fouls}
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        UpdatePlayerStatProcessor.process(event_log, fiba_scoresheet)

      [player] = result_scoresheet.team_a.players

      # Should have 5 fouls total: 1 existing P + 1 F + 3 additional F
      assert length(player.fouls) == 5

      # Should have 4 F fouls total
      f_fouls = Enum.filter(player.fouls, fn foul -> foul.type == "F" end)
      assert length(f_fouls) == 4
    end
  end
end
