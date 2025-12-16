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
  end
end
