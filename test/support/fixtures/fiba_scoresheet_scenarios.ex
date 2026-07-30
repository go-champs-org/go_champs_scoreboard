defmodule GoChampsScoreboard.FibaScoresheetScenarios do
  @moduledoc """
  Hand-built event-log scenario builders for the FIBA scoresheet regression
  suite (see `test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs`).

  Each function here drives real events through `Handler.handle/2` +
  `GoChampsScoreboard.Games.EventLogs.persist/2` (and, where the scenario
  calls for it, `EventLogs.delete/3`, `EventLogs.update_payload/4`, or
  `EventLogs.add/3`) to produce real, DB-backed event logs for a fresh game.
  This mirrors the pattern used by `game_full_event_log_fixture/0` in
  `test/support/fixtures/events_fixtures.ex` and is required because
  `GoChampsScoreboard.Sports.Basketball.Reports.fetch_report_data/2` reads
  event logs back from the database — it cannot be fed an in-memory list.

  Every function returns the `game_id` for the scenario so the caller can do:

      game_id = FibaScoresheetScenarios.normal_game_scenario_fixture()
      result = GoChampsScoreboard.Sports.Basketball.Reports.fetch_report_data("fiba-scoresheet", game_id)

  The golden JSON fixtures these scenarios are checked against live under
  `test/fixtures/fiba_scoresheet/<scenario_name>.json` and were produced by
  running the scenario once, manually verifying the output against the
  events fed in, then committing that output as the expected contract.
  """

  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.InfoState
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Games.EventLogs
  import GoChampsScoreboard.GameStateFixtures

  # Fixed so the resulting FibaScoresheet.Info#datetime is deterministic across
  # test runs (game_state_with_players_fixture/1 defaults info_state to
  # InfoState.new(DateTime.utc_now()) otherwise, which would bake a
  # wall-clock timestamp into the golden JSON fixtures and make every future
  # run fail the comparison).
  @fixed_datetime ~U[2025-01-01 12:00:00Z]

  @doc """
  Happy path: a straightforward `persist/2` sequence with two players per
  team, scoring across two periods (2PT/FT for home, 3PT/FT for away) plus
  one personal foul, and no corrections afterwards.

  Proves: a plain sequence of persisted events produces the expected
  scores, running_score entries, points_by_period, and player fouls.
  """
  @spec normal_game_scenario_fixture() :: String.t()
  def normal_game_scenario_fixture() do
    home_players = [
      %PlayerState{
        id: "h1",
        name: "Home Ace",
        number: 4,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      },
      %PlayerState{
        id: "h2",
        name: "Home Bench",
        number: 5,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: false
      }
    ]

    away_players = [
      %PlayerState{
        id: "a1",
        name: "Away Ace",
        number: 7,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      },
      %PlayerState{
        id: "a2",
        name: "Away Bench",
        number: 8,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: false
      }
    ]

    game_state =
      game_state_with_players_fixture(
        game_id: "a0000000-0000-0000-0000-000000000001",
        home_team_name: "Eagles",
        away_team_name: "Hawks",
        home_players: home_players,
        away_players: away_players,
        info_state: InfoState.new(@fixed_datetime)
      )

    start_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        600,
        1,
        %{}
      )

    # Home: H1 made a 2PT field goal
    home_h1_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        590,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "h1",
          "stat-id" => "field_goals_made"
        }
      )

    # Home: H1 made a free throw
    home_h1_ft =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        580,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "h1",
          "stat-id" => "free_throws_made"
        }
      )

    # Away: A1 commits a personal foul
    away_a1_foul =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        570,
        1,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "a1",
          "stat-id" => "fouls_personal"
        }
      )

    # Away: A1 made a 3PT field goal
    away_a1_3pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        560,
        1,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "a1",
          "stat-id" => "three_point_field_goals_made"
        }
      )

    # Home: H2 made a 2PT field goal (still period 1)
    home_h2_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        550,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "h2",
          "stat-id" => "field_goals_made"
        }
      )

    # Away: A2 made a free throw (period 2)
    away_a2_ft =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        600,
        2,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "a2",
          "stat-id" => "free_throws_made"
        }
      )

    end_event =
      GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition.create(
        game_state.id,
        0,
        2,
        %{}
      )

    persist_sequence(game_state, [
      start_event,
      home_h1_2pt,
      home_h1_ft,
      away_a1_foul,
      away_a1_3pt,
      home_h2_2pt,
      away_a2_ft,
      end_event
    ])

    game_state.id
  end

  @doc """
  Persists a sequence of events, then deletes a middle scoring event
  (`EventLogs.delete/3`), leaving the remaining events to be re-processed
  from scratch by `Reports.fetch_report_data/2`.

  Proves: deleting an event doesn't just remove it — the running_score keys
  (which are keyed by cumulative team score) and totals for all subsequent
  events are recalculated as if the deleted event never happened.
  """
  @spec game_with_deleted_event_scenario_fixture() :: String.t()
  def game_with_deleted_event_scenario_fixture() do
    home_players = [
      %PlayerState{
        id: "c1",
        name: "Comet One",
        number: 10,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      },
      %PlayerState{
        id: "c2",
        name: "Comet Two",
        number: 11,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: false
      }
    ]

    away_players = [
      %PlayerState{
        id: "m1",
        name: "Meteor One",
        number: 20,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      }
    ]

    game_state =
      game_state_with_players_fixture(
        game_id: "a0000000-0000-0000-0000-000000000002",
        home_team_name: "Comets",
        away_team_name: "Meteors",
        home_players: home_players,
        away_players: away_players,
        info_state: InfoState.new(@fixed_datetime)
      )

    start_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        600,
        1,
        %{}
      )

    # C1 made a 2PT field goal (kept)
    c1_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        590,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "c1",
          "stat-id" => "field_goals_made"
        }
      )

    # C1 made a free throw (this one gets deleted)
    c1_ft_to_delete =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        580,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "c1",
          "stat-id" => "free_throws_made"
        }
      )

    # M1 commits a personal foul (kept)
    m1_foul =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        570,
        1,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "m1",
          "stat-id" => "fouls_personal"
        }
      )

    # C2 made a 2PT field goal (kept)
    c2_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        560,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "c2",
          "stat-id" => "field_goals_made"
        }
      )

    end_event =
      GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition.create(
        game_state.id,
        0,
        1,
        %{}
      )

    [
      _start_log,
      _c1_2pt_log,
      c1_ft_log,
      _m1_foul_log,
      _c2_2pt_log,
      _end_log
    ] =
      persist_sequence(game_state, [
        start_event,
        c1_2pt,
        c1_ft_to_delete,
        m1_foul,
        c2_2pt,
        end_event
      ])

    {:ok, _deleted} = EventLogs.delete(c1_ft_log.id)

    game_state.id
  end

  @doc """
  Persists a sequence of events, then uses `EventLogs.update_payload/4` to
  correct a made 2PT field goal into a made 3PT field goal.

  Proves: correcting a single event's payload propagates end-to-end into
  the resulting scoresheet contract (score value, running_score point type).
  """
  @spec game_with_corrected_payload_scenario_fixture() :: String.t()
  def game_with_corrected_payload_scenario_fixture() do
    home_players = [
      %PlayerState{
        id: "s1",
        name: "Sun One",
        number: 4,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      }
    ]

    away_players = [
      %PlayerState{
        id: "sh1",
        name: "Shark One",
        number: 8,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      }
    ]

    game_state =
      game_state_with_players_fixture(
        game_id: "a0000000-0000-0000-0000-000000000003",
        home_team_name: "Suns",
        away_team_name: "Sharks",
        home_players: home_players,
        away_players: away_players,
        info_state: InfoState.new(@fixed_datetime)
      )

    start_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        600,
        1,
        %{}
      )

    # S1 made a 2PT field goal (this payload gets corrected to a 3PT make)
    s1_field_goal_to_correct =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        590,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "s1",
          "stat-id" => "field_goals_made"
        }
      )

    # SH1 made a free throw (untouched control event)
    sh1_ft =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        580,
        1,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "sh1",
          "stat-id" => "free_throws_made"
        }
      )

    end_event =
      GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition.create(
        game_state.id,
        0,
        1,
        %{}
      )

    [
      _start_log,
      s1_field_goal_log,
      _sh1_ft_log,
      _end_log
    ] =
      persist_sequence(game_state, [
        start_event,
        s1_field_goal_to_correct,
        sh1_ft,
        end_event
      ])

    {:ok, _updated} =
      EventLogs.update_payload(s1_field_goal_log.id, %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "s1",
        "stat-id" => "three_point_field_goals_made"
      })

    game_state.id
  end

  @doc """
  Persists a short sequence, then uses `EventLogs.add/3` to insert an event
  after the fact with a `game_clock_time` that places it chronologically
  between two already-persisted events. This exercises
  `EventLogs.rebuild_all_snapshots/1`.

  Proves: an out-of-order add is correctly slotted into chronological order
  and the resulting scoresheet contract reflects the full, re-ordered
  sequence (not just append-at-the-end behavior).
  """
  @spec game_with_out_of_order_add_scenario_fixture() :: String.t()
  def game_with_out_of_order_add_scenario_fixture() do
    home_players = [
      %PlayerState{
        id: "b1",
        name: "Bull One",
        number: 23,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      },
      %PlayerState{
        id: "b2",
        name: "Bull Two",
        number: 33,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: false
      }
    ]

    away_players = [
      %PlayerState{
        id: "k1",
        name: "Buck One",
        number: 34,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      }
    ]

    game_state =
      game_state_with_players_fixture(
        game_id: "a0000000-0000-0000-0000-000000000004",
        home_team_name: "Bulls",
        away_team_name: "Bucks",
        home_players: home_players,
        away_players: away_players,
        info_state: InfoState.new(@fixed_datetime)
      )

    start_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        600,
        1,
        %{}
      )

    # B1 made a 2PT field goal at 9:50 remaining
    b1_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        590,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "b1",
          "stat-id" => "field_goals_made"
        }
      )

    end_event =
      GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition.create(
        game_state.id,
        0,
        1,
        %{}
      )

    persist_sequence(game_state, [start_event, b1_2pt, end_event])

    # Out-of-order add: B2 made a free throw at 5:00 remaining — chronologically
    # between B1's 2PT (9:50 remaining) and the end of the game (0:00 remaining),
    # inserted *after* both of those were already persisted.
    b2_ft_log = %EventLog{
      key: "update-player-stat",
      game_id: game_state.id,
      timestamp: DateTime.utc_now(),
      payload: %{
        "operation" => "increment",
        "team-type" => "home",
        "player-id" => "b2",
        "stat-id" => "free_throws_made"
      },
      game_clock_time: 300,
      game_clock_period: 1
    }

    {:ok, _added} = EventLogs.add(b2_ft_log)

    game_state.id
  end

  # Persists `events` in order against `game_state`, following the exact
  # pattern used by `game_full_event_log_fixture/0` in events_fixtures.ex:
  # each event is applied via `Handler.handle/2` against the *original*
  # `game_state` (not threaded cumulatively) and persisted against the
  # previous iteration's accumulator. This matters in practice because it's
  # what keeps volatile, wall-clock-derived fields (like the started_at set
  # by StartGameLiveModeDefinition) out of the snapshot that ends up backing
  # the final bootstrap step of the FIBA scoresheet contract; the contract
  # itself is otherwise built purely from replaying each event log's own
  # `payload`/`key`/clock fields, not from cumulative snapshot state.
  # Returns the list of persisted event logs, in the same order as `events`.
  defp persist_sequence(game_state, events) do
    {logs, _final_state} =
      Enum.reduce(events, {[], game_state}, fn event, {acc_logs, acc_state} ->
        reacted_game = Handler.handle(game_state, event)
        {:ok, event_log} = EventLogs.persist(event, acc_state)
        {[event_log | acc_logs], reacted_game}
      end)

    Enum.reverse(logs)
  end

  defp base_stats_values do
    %{
      "field_goals_made" => 0,
      "free_throws_made" => 0,
      "three_point_field_goals_made" => 0,
      "fouls_personal" => 0,
      "fouls_technical" => 0,
      "fouls_unsportsmanlike" => 0,
      "fouls_disqualifying" => 0,
      "fouls_disqualifying_fighting" => 0,
      "fouls_game_disqualifying" => 0
    }
  end
end
