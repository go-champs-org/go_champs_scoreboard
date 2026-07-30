defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheetRegressionTest do
  @moduledoc """
  Regression suite: event-log sequence (persist/delete/update_payload/add) ->
  `GoChampsScoreboard.Sports.Basketball.Reports.fetch_report_data("fiba-scoresheet", game_id)`
  contract.

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

  Each scenario's expected output is a golden JSON fixture under
  `test/fixtures/fiba_scoresheet/<scenario_name>.json`, loaded via
  `GoChampsScoreboard.FibaScoresheetFixtures.load_golden!/1`. These fixtures
  were produced by running the scenario once, manually verifying the
  resulting scores/fouls/running_score against the events fed into the
  scenario (see the module doc on each scenario builder for the expected
  arithmetic), then committing that output as the expected contract — they
  are a correctness check for these hand-built scenarios (unlike a
  real-game capture, where the same file would only be a regression lock).

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
end
