defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.SubstitutePlayerProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.SubstitutePlayerProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns fiba scoresheet data with started player when event log payload does not have playing-player-id" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "team-type" => "home",
            "playing-player-id" => nil,
            "bench-player-id" => "123"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{
          id: "123",
          name: "Player 1",
          number: 12,
          fouls: [],
          has_played: nil,
          has_started: nil,
          first_played_period: nil,
          is_captain: nil
        }
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        SubstitutePlayerProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_a.players == [
               %FibaScoresheet.Player{
                 id: "123",
                 name: "Player 1",
                 number: 12,
                 fouls: [],
                 has_played: true,
                 has_started: true,
                 first_played_period: event_log.game_clock_period,
                 is_captain: nil
               }
             ]
    end

    test "returns fiba scoresheet data with started player when event log payload has playing-player-id" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "team-type" => "home",
            "playing-player-id" => "124",
            "bench-player-id" => "123"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_players = [
        %FibaScoresheet.Player{
          id: "123",
          name: "Player 1",
          number: 12,
          fouls: [],
          has_played: nil,
          has_started: nil,
          first_played_period: nil,
          is_captain: nil
        }
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        SubstitutePlayerProcessor.process(event_log, fiba_scoresheet)

      assert result_scoresheet.team_a.players == [
               %FibaScoresheet.Player{
                 id: "123",
                 name: "Player 1",
                 number: 12,
                 fouls: [],
                 has_played: true,
                 has_started: nil,
                 first_played_period: event_log.game_clock_period,
                 is_captain: nil
               }
             ]
    end

    test "returns fiba scoresheet data with started player when event log payload has playing-player-id and bench-player-id but it does not overrid first_played_period" do
      game_state = basketball_game_state_fixture()

      # Event is happening in the 3rd period
      event =
        GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          3,
          %{
            "team-type" => "home",
            "playing-player-id" => "124",
            "bench-player-id" => "123"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Player 1 has already played in the 1st period
      team_a_players = [
        %FibaScoresheet.Player{
          id: "123",
          name: "Player 1",
          number: 12,
          fouls: [],
          has_played: true,
          has_started: nil,
          first_played_period: 1,
          is_captain: nil
        }
      ]

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_players: team_a_players)

      result_scoresheet =
        SubstitutePlayerProcessor.process(event_log, fiba_scoresheet)

      # The first_played_period should not be updated to 3
      assert result_scoresheet.team_a.players == [
               %FibaScoresheet.Player{
                 id: "123",
                 name: "Player 1",
                 number: 12,
                 fouls: [],
                 has_played: true,
                 has_started: nil,
                 first_played_period: 1,
                 is_captain: nil
               }
             ]
    end
  end
end
