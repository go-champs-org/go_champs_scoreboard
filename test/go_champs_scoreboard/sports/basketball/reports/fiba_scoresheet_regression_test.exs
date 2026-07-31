defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheetRegressionTest do
  @moduledoc """
  Regression suite: event-log sequence (persist/delete/update_payload/add) ->
  `GoChampsScoreboard.Sports.Basketball.Reports.fetch_report_data("fiba-scoresheet", game_id)`
  contract.

  See `test/fixtures/fiba_scoresheet/README.md` for the full two-suite
  architecture (this suite plus the JS visual-regression suite it shares
  fixtures with), how to add a new scenario, and how to capture/approve a
  real game.

  This is intentionally separate from the per-processor unit tests under
  `test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet/*_test.exs`
  (which exercise individual processor modules in isolation) and from the
  single smoke-test example in `reports_test.exs`. Each test below builds a
  scenario via `GoChampsScoreboard.FibaScoresheetScenarios`, which drives
  real events through `Handler.handle/2` + `GoChampsScoreboard.Games.EventLogs`
  (`persist/2`, and — depending on the scenario — `delete/3`,
  `update_payload/4`, or `add/3`) to produce real, DB-backed event logs. This
  is required because `Reports.fetch_report_data/2` reads event logs back
  from the database via `EventLogs.get_all_by_game_id/2` — it cannot be fed
  an in-memory list.

  Each hand-built scenario's expected output is a golden JSON fixture under
  `test/fixtures/fiba_scoresheet/<scenario_name>.json`, loaded via
  `GoChampsScoreboard.FibaScoresheetFixtures.load_golden!/1`. These fixtures
  were produced by running the scenario once, manually verifying the
  resulting scores/fouls/running_score against the events fed into the
  scenario (see the module doc on each scenario builder for the expected
  arithmetic), then committing that output as the expected contract — they
  are a correctness check for these hand-built scenarios.

  This suite also replays real games captured from production via
  `Mix.Tasks.FibaScoresheet.ExportGame` (see `lib/mix/tasks/fiba_scoresheet.export_game.ex`
  and `lib/mix/tasks/README.md`) through
  `GoChampsScoreboard.FibaScoresheetScenarios.replay_real_game_fixture!/1`.
  Those fixtures live under `test/fixtures/fiba_scoresheet/real_games/` (the
  anonymized capture as `<name>.json`, the locked expected contract as
  `<name>.expected.json`, loaded via
  `GoChampsScoreboard.FibaScoresheetFixtures.load_real_game_golden!/1`) and,
  unlike the hand-built scenarios above, are a regression lock rather than a
  correctness proof — there's no independent source of truth for what a
  real captured game's exact contract "should" be, only a one-time sanity
  check that the output looks plausible.

  The comparison is done via a JSON roundtrip (`Poison.encode!/1` then
  `Poison.decode!/1`) on both sides, matching the pattern already used
  throughout `event_logs.ex` for game_state/snapshot serialization. This
  avoids brittle struct/atom-vs-string comparisons and tests the actual wire
  contract shape the frontend receives.
  """

  use ExUnit.Case
  use GoChampsScoreboard.DataCase

  alias GoChampsScoreboard.Sports.Basketball.Reports
  alias GoChampsScoreboard.FibaScoresheetFixtures

  import GoChampsScoreboard.FibaScoresheetScenarios

  defp fetch_and_normalize(game_id) do
    "fiba-scoresheet"
    |> Reports.fetch_report_data(game_id)
    |> Poison.encode!()
    |> Poison.decode!()
  end

  describe "happy path: persist/2 sequence" do
    test "matches the golden contract for a straightforward scoring sequence" do
      game_id = normal_game_scenario_fixture()

      result = fetch_and_normalize(game_id)
      expected = FibaScoresheetFixtures.load_golden!("normal_game")

      assert result == expected
    end
  end

  describe "EventLogs.delete/3: removing a middle scoring event" do
    test "recalculates scores, running_score, and fouls for all subsequent events" do
      game_id = game_with_deleted_event_scenario_fixture()

      result = fetch_and_normalize(game_id)
      expected = FibaScoresheetFixtures.load_golden!("game_with_deleted_event")

      assert result == expected

      # Guard the intent of this scenario, not just the golden byte-match:
      # the deleted event was a home free throw (worth 1 point) sandwiched
      # between two home 2PT field goals. If delete only removed the row
      # without recalculating downstream running_score keys (which are
      # keyed by cumulative team score), the second field goal would still
      # show up under its *original* pre-delete key (5) instead of the
      # recalculated one (4).
      home_running_score = result["team_a"]["running_score"]
      assert result["team_a"]["score"] == 4
      assert Map.has_key?(home_running_score, "4")
      refute Map.has_key?(home_running_score, "5")
      refute Map.has_key?(home_running_score, "3")
    end
  end

  describe "EventLogs.update_payload/4: correcting a made 2PT into a made 3PT" do
    test "reflects the correction end-to-end in score and running_score" do
      game_id = game_with_corrected_payload_scenario_fixture()

      result = fetch_and_normalize(game_id)
      expected = FibaScoresheetFixtures.load_golden!("game_with_corrected_payload")

      assert result == expected

      # Guard the intent of this scenario: the corrected event moves 2 points
      # to 3 points for the home team, and the running_score entry's `type`
      # switches from "2PT" to "3PT" under the recalculated cumulative key.
      assert result["team_a"]["score"] == 3
      assert result["team_a"]["running_score"]["3"]["type"] == "3PT"
      refute Map.has_key?(result["team_a"]["running_score"], "2")
    end
  end

  describe "EventLogs.add/3: out-of-order insertion" do
    test "slots the added event chronologically and rebuilds a consistent contract" do
      game_id = game_with_out_of_order_add_scenario_fixture()

      result = fetch_and_normalize(game_id)
      expected = FibaScoresheetFixtures.load_golden!("game_with_out_of_order_add")

      assert result == expected

      # Guard the intent of this scenario: the added free throw (worth 1
      # point) is chronologically slotted after the existing 2PT field goal,
      # so the running_score should show both under their correct
      # cumulative keys (2 then 3), not e.g. a single entry or an
      # out-of-order key.
      home_running_score = result["team_a"]["running_score"]
      assert result["team_a"]["score"] == 3
      assert home_running_score["2"]["type"] == "2PT"
      assert home_running_score["3"]["type"] == "FT"
    end
  end

  # `game_id` is a fresh UUID generated by `replay_real_game_fixture!/1` on
  # every call (by design — so repeated replays never collide) and isn't
  # rendered anywhere visible in the scoresheet, so it's simply dropped.
  #
  # `info.actual_start_datetime`/`actual_end_datetime` come from
  # `game_state.clock_state.started_at`/`finished_at`
  # (see fiba_scoresheet_manager.ex:51-52), which are stamped with
  # `DateTime.utc_now()` in production
  # (lib/go_champs_scoreboard/sports/basketball/game_clock.ex:11,17) whenever
  # a game's clock actually starts/finishes — correct real-time behavior we
  # deliberately don't touch. The export step drops each event log's
  # original timestamp (see the Mix task's moduledoc), so replaying a
  # captured sequence re-stamps these with "now" at replay time, making them
  # different on every run. Rather than nulling them out (which left the
  # rendered scoresheet's date/time fields blank, an unrealistic baseline
  # for the visual regression suite — see
  # assets/js/components/basketball_5x5/Reports/__pdf_tests__/FibaScoresheet.visual.test.tsx),
  # both sides of the comparison are stamped with the same fixed,
  # deterministic-for-testing values instead, so the golden contract (and
  # the PDF rendered from it) shows a plausible, non-blank start/end time.
  @fixed_actual_start_datetime "2026-05-10T22:15:00Z"
  @fixed_actual_end_datetime "2026-05-11T00:10:00Z"

  defp normalize_volatile_fields(contract) do
    contract
    |> Map.delete("game_id")
    |> Map.update!("info", fn info ->
      Map.merge(info, %{
        "actual_start_datetime" => @fixed_actual_start_datetime,
        "actual_end_datetime" => @fixed_actual_end_datetime
      })
    end)
  end

  describe "real game capture: final-cbi-05-10-2026 (PINHEIROS vs SESI FRANCA, CBI)" do
    test "replays the captured, anonymized event log sequence and matches the locked contract" do
      game_id = replay_real_game_fixture!("final-cbi-05-10-2026")

      result = fetch_and_normalize(game_id)
      expected = FibaScoresheetFixtures.load_real_game_golden!("final-cbi-05-10-2026")

      assert normalize_volatile_fields(result) == normalize_volatile_fields(expected)

      # This is a regression lock, not a correctness proof (see module doc
      # and GoChampsScoreboard.FibaScoresheetFixtures.load_real_game_golden!/1)
      # — there's no independent source of truth for this real game's exact
      # contract. The expected file was produced by running this replay once
      # and sanity-checking it: both teams have positive, plausible final
      # scores, team names are preserved, and every player/coach/official
      # name is anonymized (see Mix.Tasks.FibaScoresheet.ExportGame).
      assert result["team_a"]["score"] == 81
      assert result["team_b"]["score"] == 64
      assert result["team_a"]["name"] == "PINHEIROS"
      assert result["team_b"]["name"] == "SESI FRANCA"
    end
  end
end
