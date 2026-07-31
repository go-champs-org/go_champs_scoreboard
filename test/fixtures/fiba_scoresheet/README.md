# FIBA Scoresheet Regression Suite

Two independent regression suites share the fixtures in this directory, so a change to the FIBA scoresheet contract breaks both together instead of drifting apart silently:

- **Suite 1 (Elixir)** — `test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs`: given a sequence of event-log operations (`persist`/`delete`/`update_payload`/`add`), asserts the resulting `%FibaScoresheet{}` contract matches a golden JSON fixture.
- **Suite 2 (JS)** — `assets/js/components/basketball_5x5/Reports/__pdf_tests__/FibaScoresheet.visual.test.tsx`: given the same contract, renders it through the real `@react-pdf/renderer` pipeline, rasterizes it, and pixel-diffs the result against a committed baseline PNG.

Both suites read the exact same fixture files from this directory. That's deliberate: if you change the contract's shape or the words it renders, expect **both** suites to need updating together (new golden JSON *and* new baseline PNG) — if they drift apart instead, that's exactly the kind of silent regression this architecture exists to catch.

## Fixture types

- `<scenario_name>.json` (this directory) — hand-built scenario contracts (e.g. `normal_game.json`, `game_with_deleted_event.json`). You control the input events, so you can reason about the expected output up front.
- `real_games/<name>.json` — an anonymized capture of a real game's event log sequence (`{"initial_state": ..., "event_log_sequence": [...]}`), produced by `mix fiba_scoresheet.export_game`. **Not itself a `FibaScoresheetData` contract** — it gets replayed to produce one.
- `real_games/<name>.expected.json` — the golden contract for a replayed real game. Unlike the hand-built scenarios, this is a **regression lock, not a correctness proof** — there's no independent source of truth for what a real game's exact contract "should" be, only a one-time sanity check that the replayed output looked plausible when it was committed.

## Adding a hand-built scenario

1. Add a builder function to `test/support/fixtures/fiba_scoresheet_scenarios.ex` (`GoChampsScoreboard.FibaScoresheetScenarios`), following the existing scenarios' pattern: build a `game_state_with_players_fixture/1`, construct events via the real `GoChampsScoreboard.Events.Definitions.*.create/4` modules, drive them through `Handler.handle/2` + `EventLogs.persist/2` (and `delete/3`/`update_payload/4`/`add/3` if the scenario needs to exercise a mutation), and return the resulting `game_id`.
2. Run the scenario once via `GoChampsScoreboard.Sports.Basketball.Reports.fetch_report_data("fiba-scoresheet", game_id)`, verify the output by hand against the events you fed in (scores, fouls, running_score), then commit that output as `test/fixtures/fiba_scoresheet/<scenario_name>.json`. The easiest way to produce the file: temporarily add
   ```elixir
   File.write!(
     FibaScoresheetFixtures.golden_fixture_path("<scenario_name>"),
     Poison.encode!(result, pretty: true)
   )
   ```
   inside a throwaway test, run it once, delete the `File.write!` line, and let the real `assert` compare against the file you just committed.
3. Add a `describe`/`test` block to `fiba_scoresheet_regression_test.exs` calling your new builder + `FibaScoresheetFixtures.load_golden!/1`.
4. If you want visual coverage too, add an entry to the `fixtures` array in `FibaScoresheet.visual.test.tsx` — **this is a manual step**, a new Elixir scenario does not automatically get a JS baseline — then generate its initial baseline image:
   ```bash
   node --experimental-vm-modules node_modules/.bin/jest --selectProjects pdf-render -t "<scenario_name>" -u
   ```

## Capturing a real game

```bash
# Locally, against a database you can already reach:
mix fiba_scoresheet.export_game <game_id> <output_name>

# Against production, via Heroku (see lib/mix/tasks/README.md for the full flow):
heroku run "mix fiba_scoresheet.export_game <game_id> <output_name>" -a go-champs-scoreboard-prod > <output_name>.json
```

This is **read-only** and **always anonymizes** — there is no separate scrub step to remember to run; it's built into the task itself (`lib/mix/tasks/fiba_scoresheet.export_game.ex`). Every real player/coach/official name, license number, non-blank signature, and tournament/organization/sponsor detail is replaced with a deterministic synthetic placeholder (the same identity always maps to the same placeholder, everywhere it appears — including inside event payloads, not just the base state). Left untouched, because it's what makes the fixture useful as a regression case: team names/colors/logos, IDs, and every stat/score/clock-timing value.

The task writes directly to `test/fixtures/fiba_scoresheet/real_games/<output_name>.json` when run against a locally-reachable database. When run via `heroku run`, it also prints the same JSON to stdout — redirect that to the path above yourself, as shown.

## Approving the golden output for a real game

1. In a test or `iex -S mix`, replay the capture and fetch its contract:
   ```elixir
   alias GoChampsScoreboard.FibaScoresheetScenarios
   alias GoChampsScoreboard.Sports.Basketball.Reports

   game_id = FibaScoresheetScenarios.replay_real_game_fixture!("<output_name>")
   result = Reports.fetch_report_data("fiba-scoresheet", game_id)
   ```
2. Review it: both teams should have positive, plausible scores; team names should be real; every player/coach/official name should already be anonymized (`"Player N"`/`"Coach N"`/`"Official N"`, etc. — see above).
3. Two fields are inherently non-reproducible on replay and need normalizing before you commit anything or compare in a test (see `normalize_volatile_fields/1` at the top of the real-game `describe` block in `fiba_scoresheet_regression_test.exs`):
   - `game_id` — a fresh UUID on every replay (by design, so repeated replays never collide); dropped entirely.
   - `info.actual_start_datetime`/`actual_end_datetime` — these come from `game_state.clock_state.started_at`/`finished_at` ([fiba_scoresheet_manager.ex](../../../lib/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet/fiba_scoresheet_manager.ex)), which production stamps with a real `DateTime.utc_now()` whenever a clock actually starts/finishes ([game_clock.ex](../../../lib/go_champs_scoreboard/sports/basketball/game_clock.ex)) — correct, untouched behavior. The *export* step deliberately drops each event's original timestamp, so replaying the same capture re-stamps "now" on every run. Nulling these out would leave the rendered scoresheet's date/time fields blank (an unrealistic baseline for the visual suite), so instead both sides get stamped with the same fixed, deterministic-for-testing values.
4. Once it looks right, write the normalized output to `test/fixtures/fiba_scoresheet/real_games/<output_name>.expected.json` (same throwaway-write-then-commit technique as a hand-built scenario, above) and add a `describe`/`test` block calling `replay_real_game_fixture!/1` + `FibaScoresheetFixtures.load_real_game_golden!/1`.
5. **This is a regression lock, not a correctness proof.** There's no independent source of truth for a real game's exact contract — only your one-time sanity check above. If this test fails later, that means something *changed*, not necessarily that the new output is *wrong* — go look at what changed and judge it on its own merits before assuming the fixture needs updating.
6. Add the new `.expected.json` to the `fixtures` array in `FibaScoresheet.visual.test.tsx` — explicitly the `.expected.json` file, never the sibling raw `real_games/<output_name>.json` capture, which is a different shape entirely and isn't a `FibaScoresheetData` contract — and generate its baseline image the same way as a hand-built scenario (step 4 above).

## Running each suite

```bash
# Suite 1 (Elixir), all scenarios:
mix test test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs

# Suite 2 (JS), the visual project specifically (needs --experimental-vm-modules;
# this project loads @react-pdf/renderer and pdfjs-dist as real ESM):
node --experimental-vm-modules node_modules/.bin/jest --selectProjects pdf-render

# Suite 2, a single fixture:
node --experimental-vm-modules node_modules/.bin/jest --selectProjects pdf-render -t "<fixture_name>"

# Everything, including the rest of the frontend test suite:
npm test
```

**Updating snapshots intentionally:**
- Elixir: there's no `-u` — regenerate a golden fixture the same way you created it (temporary `File.write!` + manual review, see above), never by blindly trusting a failing test's actual output.
- JS: `npm test -- -u` updates every image snapshot at once; scope it to one fixture with
  ```bash
  node --experimental-vm-modules node_modules/.bin/jest --selectProjects pdf-render -t "<fixture_name>" -u
  ```
  so you don't accidentally paper over a real regression in an unrelated fixture while you're at it. Either way, **look at the diff before you regenerate anything** — `jest-image-snapshot` writes the failing comparison's diff image to `__pdf_tests__/__image_snapshots__/__diff_output__/<name>-page-<n>-diff.png`; that image is the entire reason this suite exists, so actually open it before deciding the new output is correct.

## If this suite breaks, start here

Most failures fall into one of three buckets:
1. **An intentional contract shape change** (a new field on `%FibaScoresheet{}`, a renamed key, a wording change in the rendered PDF) — update the golden fixture(s) *and* the JS baseline(s) together, in the same change. If they drift apart, that's exactly the failure mode this two-suite architecture exists to catch.
2. **A real regression** in a processor (`lib/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet/*_processor.ex`) or a rendering component (`assets/js/components/basketball_5x5/Reports/FibaScoresheet*.tsx`) — fix the code, don't touch the fixture.
3. **A pixel-diff threshold that's too tight** for legitimate minor rendering noise (Suite 2 only) — see `IMAGE_SNAPSHOT_OPTIONS` in `FibaScoresheet.visual.test.tsx`. Read its inline comment on units before touching it: `jest-image-snapshot`'s `failureThresholdType: 'percent'` is actually compared as a raw `0-1` fraction of `diffPixelCount / totalPixels`, not a `0-100` percentage — `0.01` means "1% of pixels may differ," not "0.01%." Getting this wrong in either direction is easy and has already bitten this suite once.
