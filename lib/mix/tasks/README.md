# Mix Tasks

This directory contains custom Mix tasks for the Go Champs Scoreboard application. These tasks provide command-line utilities for various administrative, data-export, and maintenance operations.

It lives under `lib/mix/tasks/` (not a top-level `mix/tasks/`) because Mix only compiles code under `lib/` (see `elixirc_paths/1` in `mix.exs`) — a task placed outside `lib/` won't be picked up as a `mix <name>` command.

## Available Tasks

### 1. FIBA Scoresheet Game Export (`mix fiba_scoresheet.export_game`)

Exports a game's full event log sequence into an anonymized JSON fixture that can be replayed offline to reproduce and regression-test its FIBA scoresheet contract (see `test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs` and `GoChampsScoreboard.FibaScoresheetScenarios.replay_real_game_fixture!/1`).

**Usage:**
```bash
mix fiba_scoresheet.export_game <game_id> <output_name>
```

**Arguments:**
- `game_id` - The ID of the game to export (required)
- `output_name` - File name to write, without extension (required). Output goes to `test/fixtures/fiba_scoresheet/real_games/<output_name>.json`.

**What it does:**
- Read-only — it only calls `EventLogs.get_all_by_game_id/2` and never writes to the database.
- Anonymizes every real player/coach/official name, license number, signature, and tournament/organization/sponsor detail it finds, deterministically (the same person always maps to the same placeholder across the whole fixture).
- Leaves every score/stat/clock-timing value untouched, since those are what make the fixture useful for regression testing.

**Running against production:**
```bash
MIX_ENV=prod \
SECRET_KEY_BASE=$(mix phx.gen.secret) \
DATABASE_URL="ecto://USER:PASSWORD@HOST/DATABASE_NAME" \
mix fiba_scoresheet.export_game <game_id> <output_name>
```
- `DATABASE_URL` should point at production. Read-only credentials or a replica are strongly preferred — the task itself only reads, but the app boots with whatever permissions the connection grants.
- `SECRET_KEY_BASE` isn't used by the task, but Phoenix requires it to boot under `MIX_ENV=prod`; any value works, `mix phx.gen.secret` generates one.
- Leave `PHX_SERVER` unset so the web server doesn't try to bind a port.
- You'll need network access to the production database from wherever you run this (VPN, bastion host, SSH tunnel, etc.).

The exported file is already anonymized and safe to share — a quick manual look before sharing is still good practice to confirm nothing unexpected slipped through.

## Adding a New Task

- Add the task module under `lib/mix/tasks/`, named `Mix.Tasks.<Namespace>.<Action>` (e.g. `Mix.Tasks.FibaScoresheet.ExportGame`), which maps to the CLI invocation `mix <namespace>.<action>`.
- Keep the argument-parsing (`run/1`) thin and delegate to a plain, testable function, so the task's logic can be exercised directly from tests without shelling out to `mix`.
- Add a numbered entry to this README describing usage, arguments, and what the task does.
