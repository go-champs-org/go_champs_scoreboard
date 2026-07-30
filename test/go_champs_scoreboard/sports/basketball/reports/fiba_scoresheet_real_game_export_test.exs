defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheetRealGameExportTest do
  @moduledoc """
  Proves the export -> anonymize -> replay pipeline for real-game fixtures:

    * `Mix.Tasks.FibaScoresheet.ExportGame.export_game/2`
      (`lib/mix/tasks/fiba_scoresheet.export_game.ex`)
    * `GoChampsScoreboard.FibaScoresheetScenarios.replay_real_game_fixture!/1`
      (`test/support/fixtures/fiba_scoresheet_scenarios.ex`)

  There is no actual production game reachable from this environment, so a
  hand-built, DB-backed "captured game" (built below, deliberately with a
  full roster: player license numbers/signatures, a coach, an official, a
  protest, tournament/organization info, and a sponsor -- everything the
  anonymization pass is supposed to touch) stands in for "a real game
  pulled from production."

  This is NOT a correctness check against a known-good production answer --
  there is no such reference available here. It instead proves the
  MECHANISM: exporting a captured game's event logs, anonymizing the
  initial state (and any PII carried in event payloads), and replaying the
  sequence through the real production code path (`Handler.handle/2` +
  `EventLogs.persist/2`) reproduces the exact same scores / running_score /
  points_by_period / fouls as the source game, while every PII-bearing
  field (names, license numbers, signature, username, tournament/
  organization info, sponsor, protest player name) comes out different
  from the source's real values.

  The fixture this test writes to `test/fixtures/fiba_scoresheet/real_games/`
  is a byproduct of proving the mechanism works, not a fixture from an
  actual production game -- it is removed after the test runs (see
  `on_exit/1` below) rather than committed as a permanent regression
  fixture.
  """

  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Games.Models.InfoState
  alias GoChampsScoreboard.Games.Models.ProtestState
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Sports.Basketball.Basketball
  alias Mix.Tasks.FibaScoresheet.ExportGame

  import GoChampsScoreboard.GameStateFixtures
  import GoChampsScoreboard.FibaScoresheetScenarios

  @output_name "real_game_export_pipeline_proof"
  @fixed_datetime ~U[2025-02-01 18:00:00Z]

  defp fetch_and_normalize(game_id) do
    "fiba-scoresheet"
    |> Reports.fetch_report_data(game_id)
    |> Poison.encode!()
    |> Poison.decode!()
  end

  defp fixture_path do
    GoChampsScoreboard.FibaScoresheetFixtures.real_game_fixture_path(@output_name)
  end

  test "export -> anonymize -> replay reproduces the source game's outcome while changing PII" do
    source_game_id = captured_game_with_full_roster_fixture()
    source_contract = fetch_and_normalize(source_game_id)

    {:ok, path} = ExportGame.export_game(source_game_id, @output_name)
    assert path == fixture_path()
    on_exit(fn -> File.rm(path) end)

    replayed_game_id = replay_real_game_fixture!(@output_name)
    replayed_contract = fetch_and_normalize(replayed_game_id)

    # --- Faithful replay: the numeric/structural game outcome is unchanged ---

    assert replayed_contract["team_a"]["score"] == source_contract["team_a"]["score"]
    assert replayed_contract["team_b"]["score"] == source_contract["team_b"]["score"]

    assert replayed_contract["team_a"]["running_score"] ==
             source_contract["team_a"]["running_score"]

    assert replayed_contract["team_b"]["running_score"] ==
             source_contract["team_b"]["running_score"]

    assert replayed_contract["team_a"]["points_by_period"] ==
             source_contract["team_a"]["points_by_period"]

    assert replayed_contract["team_b"]["points_by_period"] ==
             source_contract["team_b"]["points_by_period"]

    assert fouls_by_number(replayed_contract["team_a"]) ==
             fouls_by_number(source_contract["team_a"])

    assert fouls_by_number(replayed_contract["team_b"]) ==
             fouls_by_number(source_contract["team_b"])

    # --- Anonymization actually changed PII, not just passed it through ---

    source_player_names = player_names(source_contract)
    replayed_player_names = player_names(replayed_contract)

    assert source_player_names == [
             "Real Player Home One",
             "Real Player Home Two",
             "Real Player Away One"
           ]

    refute replayed_player_names == source_player_names
    assert Enum.all?(replayed_player_names, &String.starts_with?(&1, "Player "))

    source_licenses = license_numbers(source_contract)
    replayed_licenses = license_numbers(replayed_contract)
    refute replayed_licenses == source_licenses
    assert Enum.all?(replayed_licenses, &String.starts_with?(&1, "LICENSE-"))

    refute replayed_contract["team_a"]["coach"]["name"] ==
             source_contract["team_a"]["coach"]["name"]

    assert source_contract["team_a"]["coach"]["name"] == "Real Home Coach"
    assert String.starts_with?(replayed_contract["team_a"]["coach"]["name"], "Coach ")

    refute replayed_contract["team_a"]["coach"]["signature"] ==
             source_contract["team_a"]["coach"]["signature"]

    refute replayed_contract["scorer"]["name"] == source_contract["scorer"]["name"]
    assert source_contract["scorer"]["name"] == "Real Official Name"
    assert String.starts_with?(replayed_contract["scorer"]["name"], "Official ")

    refute replayed_contract["info"]["tournament_name"] ==
             source_contract["info"]["tournament_name"]

    assert source_contract["info"]["tournament_name"] == "Real Tournament Name"
    assert replayed_contract["info"]["tournament_name"] == "Synthetic Tournament"

    refute replayed_contract["info"]["organization_name"] ==
             source_contract["info"]["organization_name"]

    refute replayed_contract["info"]["location"] == source_contract["info"]["location"]
    refute replayed_contract["info"]["city"] == source_contract["info"]["city"]

    source_sponsor_names = source_contract["info"]["sponsors"] |> Enum.map(& &1["name"])
    replayed_sponsor_names = replayed_contract["info"]["sponsors"] |> Enum.map(& &1["name"])
    assert source_sponsor_names == ["Real Sponsor Co"]
    refute replayed_sponsor_names == source_sponsor_names

    # The protest carries no name directly (only a player_id) -- its
    # player_name is resolved by looking up the (already-anonymized) player
    # roster at report-generation time, so it comes out anonymized "for
    # free" without the export task needing to touch protest state at all.
    assert source_contract["protest"]["player_name"] == "Real Player Home One"

    refute replayed_contract["protest"]["player_name"] ==
             source_contract["protest"]["player_name"]

    assert String.starts_with?(replayed_contract["protest"]["player_name"], "Player ")
  end

  defp player_names(contract) do
    (contract["team_a"]["players"] ++ contract["team_b"]["players"])
    |> Enum.map(& &1["name"])
  end

  defp license_numbers(contract) do
    (contract["team_a"]["players"] ++ contract["team_b"]["players"])
    |> Enum.map(& &1["license_number"])
    |> Enum.reject(&(&1 in [nil, ""]))
  end

  defp fouls_by_number(team_contract) do
    team_contract["players"]
    |> Enum.map(&{&1["number"], &1["fouls"]})
    |> Enum.sort()
  end

  # A hand-built, DB-backed stand-in for "a real game pulled from
  # production": deliberately carries one of every PII-bearing field the
  # export task's anonymization pass is supposed to scrub (player license
  # numbers/signatures, a coach with a signature, an official with a
  # license/signature/username, tournament/organization info, a sponsor,
  # and a protest), plus enough scoring/foul events to exercise the numeric
  # side of the "faithful replay" assertions above.
  defp captured_game_with_full_roster_fixture do
    home_players = [
      %PlayerState{
        id: "cap-h1",
        name: "Real Player Home One",
        number: 4,
        license_number: "REAL-LIC-H1",
        signature: "data:image/png;base64,REALSIGH1",
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      },
      %PlayerState{
        id: "cap-h2",
        name: "Real Player Home Two",
        number: 5,
        license_number: "REAL-LIC-H2",
        signature: nil,
        stats_values: base_stats_values(),
        state: :available,
        is_captain: false
      }
    ]

    away_players = [
      %PlayerState{
        id: "cap-a1",
        name: "Real Player Away One",
        number: 7,
        license_number: "REAL-LIC-A1",
        signature: "data:image/png;base64,REALSIGA1",
        stats_values: base_stats_values(),
        state: :available,
        is_captain: true
      }
    ]

    home_coaches = [
      %CoachState{
        id: "cap-hc1",
        name: "Real Home Coach",
        type: :head_coach,
        state: :available,
        stats_values: Basketball.bootstrap_coach_stats(),
        signature: "data:image/png;base64,REALCOACHSIG"
      }
    ]

    officials = [
      %OfficialState{
        id: "cap-o1",
        name: "Real Official Name",
        type: :scorer,
        license_number: "REAL-OFFICIAL-LIC",
        federation: "FIBA",
        signature: "data:image/png;base64,REALOFFICIALSIG",
        username: "real.official.username"
      }
    ]

    info_state = %InfoState{
      datetime: @fixed_datetime,
      tournament_id: "real-tournament-id",
      tournament_name: "Real Tournament Name",
      tournament_slug: "real-tournament",
      tournament_logo_url: "https://real-cdn.example.com/tournament-logo.png",
      organization_name: "Real Organization Name",
      organization_slug: "real-org",
      organization_logo_url: "https://real-cdn.example.com/org-logo.png",
      location: "Real Arena",
      city: "Real City",
      number: "G001",
      game_report: "Real free-text game report mentioning real people.",
      web_url: "https://go-champs.example.com/games/real-game",
      result_type: :automatic,
      assets: [],
      sponsors: [
        %{
          name: "Real Sponsor Co",
          link: "https://realsponsor.example.com",
          logo_url: "https://real-cdn.example.com/sponsor-logo.png"
        }
      ]
    }

    protest_state = ProtestState.new(:home, "cap-h1", :protest_filed)

    game_state =
      game_state_with_players_fixture(
        home_team_name: "Comets",
        away_team_name: "Meteors",
        home_players: home_players,
        away_players: away_players,
        info_state: info_state,
        protest_state: protest_state,
        officials: officials
      )

    # game_state_with_players_fixture/1's add_coaches_to_team helper (Part
    # A's, in test/support/fixtures/game_state_fixtures.ex) rebuilds each
    # coach as a plain map with only id/name/type/stats_values, dropping
    # :signature -- fine for Part A's own scenarios (which never assert on
    # coach signatures) but not for this test, which specifically needs to
    # prove coach signature anonymization. Patch the full %CoachState{}
    # structs back in directly instead.
    game_state = %{
      game_state
      | home_team: %{game_state.home_team | coaches: home_coaches}
    }

    start_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        600,
        1,
        %{}
      )

    home_h1_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        590,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "cap-h1",
          "stat-id" => "field_goals_made"
        }
      )

    home_h1_ft =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        580,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "cap-h1",
          "stat-id" => "free_throws_made"
        }
      )

    away_a1_foul =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        570,
        1,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "cap-a1",
          "stat-id" => "fouls_personal"
        }
      )

    away_a1_3pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        560,
        1,
        %{
          "operation" => "increment",
          "team-type" => "away",
          "player-id" => "cap-a1",
          "stat-id" => "three_point_field_goals_made"
        }
      )

    home_h2_2pt =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        550,
        1,
        %{
          "operation" => "increment",
          "team-type" => "home",
          "player-id" => "cap-h2",
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

    persist_true_accumulation(game_state, [
      start_event,
      home_h1_2pt,
      home_h1_ft,
      away_a1_foul,
      away_a1_3pt,
      home_h2_2pt,
      end_event
    ])

    game_state.id
  end

  # Threads the actual post-handle game state from one event to the next,
  # matching production's GoChampsScoreboard.Infrastructure.GameEventsListener
  # (`EventLogs.persist(event, game_state_after_handling)`) -- see the
  # doc on `FibaScoresheetScenarios.replay_real_game_fixture!/1` for why
  # this test uses true accumulation rather than Part A's
  # `persist_sequence/2` convention.
  defp persist_true_accumulation(game_state, events) do
    Enum.reduce(events, game_state, fn event, acc_state ->
      reacted_state = Handler.handle(acc_state, event)
      {:ok, _event_log} = EventLogs.persist(event, reacted_state)
      reacted_state
    end)
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
