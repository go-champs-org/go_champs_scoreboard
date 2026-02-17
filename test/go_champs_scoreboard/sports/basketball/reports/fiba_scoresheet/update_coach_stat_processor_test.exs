defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessorTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.EventLogs

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetFixtures

  describe "process/2" do
    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_technical operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "C",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_disqualifying operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "D",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_technical_bench operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "coach-id" => "away-coach-id",
            "stat-id" => "fouls_technical_bench"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_coach =
        %FibaScoresheet.Coach{
          id: "away-coach-id",
          name: "Coach 2",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_coach: team_b_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "B",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_b.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_b.all_fouls == []
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_technical_bench_disqualifying operation is increment and team-type is away" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "away",
            "coach-id" => "away-coach-id",
            "stat-id" => "fouls_technical_bench_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_b_coach =
        %FibaScoresheet.Coach{
          id: "away-coach-id",
          name: "Coach 2",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_b_coach: team_b_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "BD",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_b.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_b.all_fouls == []
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_game_disqualifying operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_game_disqualifying"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "GD",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns a fiba scoresheet data coach fouls when event log payload with fouls_disqualifying_fighting operation is increment and team-type is home" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      # Coach with 0 fouls receiving a fighting foul should have 3 F fouls total
      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "F",
          extra_action: nil,
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns a fiba scoresheet data coach fouls with extra_action when event log payload includes metadata free-throws-awarded" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical",
            "metadata" => %{
              "free-throws-awarded" => "2"
            }
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      expected_fouls = [
        %FibaScoresheet.Foul{
          type: "C",
          extra_action: "2",
          period: game_state.clock_state.period,
          is_last_of_half: false
        }
      ]

      coach = result_scoresheet.team_a.coach

      assert coach.fouls == expected_fouls
      assert result_scoresheet.team_a.all_fouls == []
    end

    test "returns unchanged fiba scoresheet when event log payload has non-foul stat-id" do
      # Create a mock event log directly to avoid the event handler validation
      event_log = %GoChampsScoreboard.Events.EventLog{
        key: "update-coach-stat",
        game_id: "test-game-id",
        timestamp: DateTime.utc_now(),
        game_clock_period: 1,
        game_clock_time: 600,
        payload: %{
          "operation" => "increment",
          "team-type" => "home",
          "coach-id" => "coach-id",
          "stat-id" => "some_other_stat"
        },
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      original_fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, original_fiba_scoresheet)

      # Should be unchanged since it's not a foul stat
      assert result_scoresheet == original_fiba_scoresheet
    end

    test "skips processing when coach-id does not exist in scoresheet" do
      game_state = basketball_game_state_fixture()

      # Use the first coach from the game state
      existing_coach_in_game = List.first(game_state.home_team.coaches)

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => existing_coach_in_game.id,
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Create scoresheet with different coach ID (not the one from event)
      team_a_coach =
        %FibaScoresheet.Coach{
          id: "different-coach-id",
          name: "Different Coach",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      # Should be unchanged since coach was not found in scoresheet
      assert result_scoresheet == fiba_scoresheet

      # Verify no fouls were added to any coach
      assert result_scoresheet.team_a.coach.fouls == []
      assert result_scoresheet.team_a.assistant_coach.fouls == []
    end

    test "automatically adds GD foul when coach receives 2nd technical foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Coach already has 1 technical foul
      existing_fouls = [
        %FibaScoresheet.Foul{type: "C", period: 1, extra_action: nil, is_last_of_half: false}
      ]

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: existing_fouls
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 3 fouls total: 1 existing C + 1 new C + 1 automatic GD
      assert length(coach.fouls) == 3

      # Check foul types
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert "C" in foul_types
      assert "GD" in foul_types

      # Count each type
      c_fouls = Enum.count(foul_types, fn type -> type == "C" end)
      gd_fouls = Enum.count(foul_types, fn type -> type == "GD" end)
      assert c_fouls == 2
      assert gd_fouls == 1
    end

    test "automatically adds GD foul when coach receives 3rd technical bench foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical_bench"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Coach already has 2 technical bench fouls
      existing_fouls = [
        %FibaScoresheet.Foul{type: "B", period: 1, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "B", period: 2, extra_action: nil, is_last_of_half: false}
      ]

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: existing_fouls
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 4 fouls total: 2 existing B + 1 new B + 1 automatic GD
      assert length(coach.fouls) == 4

      # Check foul types
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert "B" in foul_types
      assert "GD" in foul_types

      # Count each type
      b_fouls = Enum.count(foul_types, fn type -> type == "B" end)
      gd_fouls = Enum.count(foul_types, fn type -> type == "GD" end)
      assert b_fouls == 3
      assert gd_fouls == 1
    end

    test "automatically adds GD foul when coach has 1 technical foul and receives 2nd technical bench foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical_bench"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Coach has 1 technical foul and 1 technical bench foul
      existing_fouls = [
        %FibaScoresheet.Foul{type: "C", period: 1, extra_action: nil, is_last_of_half: false},
        %FibaScoresheet.Foul{type: "B", period: 2, extra_action: nil, is_last_of_half: false}
      ]

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: existing_fouls
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 4 fouls total: 1 existing C + 1 existing B + 1 new B + 1 automatic GD
      assert length(coach.fouls) == 4

      # Check foul types
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert "C" in foul_types
      assert "B" in foul_types
      assert "GD" in foul_types

      # Count each type
      c_fouls = Enum.count(foul_types, fn type -> type == "C" end)
      b_fouls = Enum.count(foul_types, fn type -> type == "B" end)
      gd_fouls = Enum.count(foul_types, fn type -> type == "GD" end)
      assert c_fouls == 1
      assert b_fouls == 2
      assert gd_fouls == 1
    end

    test "does not add GD foul when coach has insufficient fouls" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_technical"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 1 foul only (the technical foul added)
      assert length(coach.fouls) == 1

      # Check foul types - should not contain GD
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert foul_types == ["C"]
      refute "GD" in foul_types
    end
  end

  describe "fighting foul logic" do
    test "adds 2 additional F fouls when coach has 0 fouls and receives fighting foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: []
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 3 fouls total (1 F + 2 additional F)
      assert length(coach.fouls) == 3

      # All should be fighting fouls
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert foul_types == ["F", "F", "F"]
    end

    test "adds 1 additional F foul when coach has 1 foul and receives fighting foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Start with 1 existing foul
      existing_foul = %FibaScoresheet.Foul{
        type: "C",
        extra_action: nil,
        period: 1,
        is_last_of_half: false
      }

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: [existing_foul]
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 3 fouls total (1 existing + 1 F + 1 additional F)
      assert length(coach.fouls) == 3

      # Check foul types
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert Enum.count(foul_types, fn type -> type == "F" end) == 2
      assert Enum.count(foul_types, fn type -> type == "C" end) == 1
    end

    test "adds only 1 F foul when coach has 2 fouls and receives fighting foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Start with 2 existing fouls
      existing_fouls = [
        %FibaScoresheet.Foul{
          type: "C",
          extra_action: nil,
          period: 1,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "B",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        }
      ]

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: existing_fouls
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 3 fouls total (2 existing + 1 F)
      assert length(coach.fouls) == 3

      # Check foul types
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert Enum.count(foul_types, fn type -> type == "F" end) == 1
      assert Enum.count(foul_types, fn type -> type == "C" end) == 1
      assert Enum.count(foul_types, fn type -> type == "B" end) == 1
    end

    test "adds only 1 F foul when coach has 3 or more fouls and receives fighting foul" do
      game_state = basketball_game_state_fixture()

      event =
        GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition.create(
          game_state.id,
          game_state.clock_state.time,
          game_state.clock_state.period,
          %{
            "operation" => "increment",
            "team-type" => "home",
            "coach-id" => "coach-id",
            "stat-id" => "fouls_disqualifying_fighting"
          }
        )

      updated_game_state = GoChampsScoreboard.Events.Handler.handle(game_state, event)

      {:ok, event_log} = EventLogs.persist(event, updated_game_state)

      # Start with 3 existing fouls
      existing_fouls = [
        %FibaScoresheet.Foul{
          type: "C",
          extra_action: nil,
          period: 1,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "B",
          extra_action: nil,
          period: 2,
          is_last_of_half: false
        },
        %FibaScoresheet.Foul{
          type: "C",
          extra_action: nil,
          period: 3,
          is_last_of_half: false
        }
      ]

      team_a_coach =
        %FibaScoresheet.Coach{
          id: "coach-id",
          name: "Coach 1",
          fouls: existing_fouls
        }

      fiba_scoresheet =
        fiba_scoresheet_fixture(game_id: event_log.game_id, team_a_coach: team_a_coach)

      result_scoresheet =
        UpdateCoachStatProcessor.process(event_log, fiba_scoresheet)

      coach = result_scoresheet.team_a.coach

      # Should have 4 fouls total (3 existing + 1 F)
      assert length(coach.fouls) == 4

      # Check foul types - should only add 1 F foul
      foul_types = Enum.map(coach.fouls, fn foul -> foul.type end)
      assert Enum.count(foul_types, fn type -> type == "F" end) == 1
      assert Enum.count(foul_types, fn type -> type == "C" end) == 2
      assert Enum.count(foul_types, fn type -> type == "B" end) == 1
    end
  end
end
