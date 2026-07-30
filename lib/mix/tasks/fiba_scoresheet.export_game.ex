defmodule Mix.Tasks.FibaScoresheet.ExportGame do
  @shortdoc "Exports a game's event log sequence into an anonymized FIBA scoresheet fixture"

  @moduledoc """
  Exports the event log sequence for a given `game_id` into an anonymized
  JSON fixture that can be replayed later via
  `GoChampsScoreboard.FibaScoresheetScenarios.replay_real_game_fixture!/1`
  (see `test/support/fixtures/fiba_scoresheet_scenarios.ex`).

  ## Usage

      mix fiba_scoresheet.export_game <game_id> <output_name>

  This writes
  `test/fixtures/fiba_scoresheet/real_games/<output_name>.json`, containing:

      {
        "initial_state": <anonymized GameState, JSON-encoded>,
        "event_log_sequence": [
          {"key": ..., "payload": ..., "game_clock_time": ..., "game_clock_period": ...},
          ...
        ]
      }

  `initial_state` is the **first** event log's snapshot state (the immutable
  base state that `GoChampsScoreboard.Games.EventLogs.rebuild_all_snapshots/1`
  also treats as the base to replay from — see
  `lib/go_champs_scoreboard/games/event_logs.ex` around lines 754-812).
  Every subsequent event log is reduced to just `key`, `payload`,
  `game_clock_time`, and `game_clock_period` — `id`, `timestamp`, and
  `snapshot` are dropped because they are regenerated on replay.

  This task is written generically against whatever `Repo`/database
  configuration is active when it's invoked (via `Mix.Task.run("app.start")`),
  so it can be pointed at a production (or production-replica, read-only)
  connection by configuring the environment accordingly — it does not
  hardcode any environment or connection details itself.

  ## Anonymization (always on, not optional)

  Before anything is written to disk, every field that is realistically PII
  in production data is replaced with a clearly-synthetic, deterministic
  placeholder:

    * Player / coach / official **names** -> `"Player 1"`, `"Coach 1"`,
      `"Official 1"`, etc., assigned deterministically per identity (by
      `id` where available) so the same person always maps to the same
      placeholder and different people never collide.
    * Player / official **license numbers** -> `"LICENSE-0001"` /
      `"OFFICIAL-LICENSE-0001"`.
    * Player / coach / official **signatures** -> `"SIGNATURE-0001"` (a
      present-but-non-blank signature is always replaced; a blank/nil
      signature is left as-is so "did this person sign" stays accurate).
    * Official **usernames** -> `"official1"`.
    * Tournament / organization **names** and **logo URLs**, sponsor
      **names/links/logos**, and game **location/city** -> synthetic
      placeholders.
    * The free-text game **report** -> a generic placeholder sentence
      (production game reports are free text and could name real people).

  Deliberately left untouched because it identifies the *game*, not a
  *person*, and isn't scrubbed by this pass: team names, tri-codes, team
  colors/logos, tournament/organization IDs and slugs, the game's `number`
  and `web_url`, and every count/stat/score/clock-timing value (those are
  exactly what makes the fixture useful as a regression case).

  The protest player's name is *not* separately anonymized here: the FIBA
  scoresheet contract resolves `protest.player_name` by looking up the
  player by ID at report-generation time (see
  `GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.ProtestManager`),
  so anonymizing the roster automatically anonymizes the protest name too.

  ## Known limitation

  Some event payloads add a brand-new player/coach/official without
  carrying an `id` (e.g. `add-coach-to-team`, or `add-player-to-team`
  when no `id` was supplied). Replaying such an event via
  `Handler.handle/2` generates a *new* random ID, which cannot be
  correlated back to whatever ID a later event log in the same capture
  might separately reference for that same person. This mirrors how
  `test/support/fixtures/fiba_scoresheet_scenarios.ex`'s hand-built
  scenarios already replay events (directly through `Handler.handle/2` +
  `EventLogs.persist/2`, not through the ID-preserving
  `EventLogs.apply_to_game_state/2` / `rebuild_all_snapshots/1` path), so
  it is an existing, accepted characteristic of how these fixtures are
  replayed rather than something specific to this task.
  """

  use Mix.Task

  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.EventLog

  @impl Mix.Task
  def run(argv) do
    Mix.Task.run("app.start")

    case argv do
      [game_id, output_name] ->
        case export_game(game_id, output_name) do
          {:ok, path} ->
            Mix.shell().info("Exported anonymized fixture for game #{game_id} to #{path}")

          {:error, reason} ->
            Mix.raise("Failed to export game #{game_id}: #{inspect(reason)}")
        end

      _ ->
        Mix.raise("Usage: mix fiba_scoresheet.export_game <game_id> <output_name>")
    end
  end

  @doc """
  Core export logic, kept as a plain function (separate from `run/1`'s CLI
  parsing) so it can be called directly from tests without shelling out to
  the Mix task.

  Fetches every event log for `game_id` (with snapshots preloaded), takes
  the first event log's snapshot state as the immutable `initial_state`,
  reduces every subsequent event log to its replayable fields, anonymizes
  everything (see the module doc), and writes the result to
  `test/fixtures/fiba_scoresheet/real_games/<output_name>.json`.
  """
  @spec export_game(String.t(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def export_game(game_id, output_name) do
    case EventLogs.get_all_by_game_id(game_id, with_snapshot: true) do
      [] ->
        {:error, :no_event_logs_found}

      [first_event_log | rest_event_logs] ->
        {anonymized_initial_state, ctx} = anonymize_game_state(first_event_log.snapshot.state)

        {anonymized_sequence, _ctx} =
          rest_event_logs
          |> Enum.map(&extract_replayable_fields/1)
          |> anonymize_event_log_sequence(ctx)

        fixture = %{
          "initial_state" => anonymized_initial_state,
          "event_log_sequence" => anonymized_sequence
        }

        path = fixture_output_path(output_name)
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, Poison.encode!(fixture, pretty: true))

        {:ok, path}
    end
  end

  @spec fixture_output_path(String.t()) :: String.t()
  defp fixture_output_path(output_name) do
    # Mirrors GoChampsScoreboard.FibaScoresheetFixtures.real_game_fixture_path/1
    # (test/support/fixtures/fiba_scoresheet_fixtures.ex). Duplicated here
    # (rather than calling into that module) because test/support is only
    # compiled for MIX_ENV=test, while this task must compile in every
    # environment.
    File.cwd!()
    |> Path.join("test/fixtures/fiba_scoresheet/real_games")
    |> Path.join("#{output_name}.json")
  end

  @spec extract_replayable_fields(EventLog.t()) :: map()
  defp extract_replayable_fields(event_log) do
    %{
      "key" => event_log.key,
      "payload" => event_log.payload,
      "game_clock_time" => event_log.game_clock_time,
      "game_clock_period" => event_log.game_clock_period
    }
  end

  # --- Anonymization -------------------------------------------------------
  #
  # `ctx` threads id -> placeholder maps (so the same identity always gets
  # the same placeholder, whether it's seen in `initial_state` or later in
  # an event payload) plus a monotonically increasing counter per category.

  defp new_anonymization_ctx do
    %{
      player_names: %{},
      player_counter: 0,
      player_licenses: %{},
      license_counter: 0,
      signatures: %{},
      signature_counter: 0,
      coach_names: %{},
      coach_counter: 0,
      official_names: %{},
      official_counter: 0,
      official_licenses: %{},
      official_license_counter: 0,
      official_usernames: %{},
      username_counter: 0
    }
  end

  @spec anonymize_game_state(GameState.t()) :: {GameState.t(), map()}
  defp anonymize_game_state(%GameState{} = state) do
    ctx = new_anonymization_ctx()

    {home_team, ctx} = anonymize_team(state.home_team, ctx)
    {away_team, ctx} = anonymize_team(state.away_team, ctx)
    {officials, ctx} = Enum.map_reduce(state.officials || [], ctx, &anonymize_official/2)

    info = anonymize_info(state.info)

    anonymized = %{
      state
      | home_team: home_team,
        away_team: away_team,
        officials: officials,
        info: info
    }

    {anonymized, ctx}
  end

  defp anonymize_team(team, ctx) do
    {players, ctx} = Enum.map_reduce(team.players || [], ctx, &anonymize_player/2)
    {coaches, ctx} = Enum.map_reduce(team.coaches || [], ctx, &anonymize_coach/2)

    {%{team | players: players, coaches: coaches}, ctx}
  end

  defp anonymize_player(player, ctx) do
    {name, ctx} =
      anonymize_field(
        ctx,
        :player_names,
        :player_counter,
        player.id,
        player.name,
        &"Player #{&1}",
        true
      )

    {license, ctx} =
      anonymize_field(
        ctx,
        :player_licenses,
        :license_counter,
        player.id,
        Map.get(player, :license_number),
        &"LICENSE-#{pad(&1)}",
        false
      )

    {signature, ctx} =
      anonymize_field(
        ctx,
        :signatures,
        :signature_counter,
        player.id,
        Map.get(player, :signature),
        &"SIGNATURE-#{pad(&1)}",
        false
      )

    {%{player | name: name, license_number: license, signature: signature}, ctx}
  end

  defp anonymize_coach(coach, ctx) do
    {name, ctx} =
      anonymize_field(
        ctx,
        :coach_names,
        :coach_counter,
        coach.id,
        coach.name,
        &"Coach #{&1}",
        true
      )

    {signature, ctx} =
      anonymize_field(
        ctx,
        :signatures,
        :signature_counter,
        coach.id,
        Map.get(coach, :signature),
        &"SIGNATURE-#{pad(&1)}",
        false
      )

    {%{coach | name: name, signature: signature}, ctx}
  end

  defp anonymize_official(official, ctx) do
    {name, ctx} =
      anonymize_field(
        ctx,
        :official_names,
        :official_counter,
        official.id,
        official.name,
        &"Official #{&1}",
        true
      )

    {license, ctx} =
      anonymize_field(
        ctx,
        :official_licenses,
        :official_license_counter,
        official.id,
        Map.get(official, :license_number),
        &"OFFICIAL-LICENSE-#{pad(&1)}",
        false
      )

    {signature, ctx} =
      anonymize_field(
        ctx,
        :signatures,
        :signature_counter,
        official.id,
        Map.get(official, :signature),
        &"SIGNATURE-#{pad(&1)}",
        false
      )

    {username, ctx} =
      anonymize_field(
        ctx,
        :official_usernames,
        :username_counter,
        official.id,
        Map.get(official, :username),
        &"official#{&1}",
        false
      )

    {%{official | name: name, license_number: license, signature: signature, username: username},
     ctx}
  end

  defp anonymize_info(info) do
    %{
      info
      | tournament_name: anonymize_text(info.tournament_name, "Synthetic Tournament"),
        organization_name: anonymize_text(info.organization_name, "Synthetic Organization"),
        tournament_logo_url:
          anonymize_text(
            info.tournament_logo_url,
            "https://example.invalid/synthetic-tournament-logo.png"
          ),
        organization_logo_url:
          anonymize_text(
            info.organization_logo_url,
            "https://example.invalid/synthetic-organization-logo.png"
          ),
        location: anonymize_text(info.location, "Synthetic Location"),
        city: anonymize_text(info.city, "Synthetic City"),
        game_report: anonymize_text(info.game_report, "Synthetic game report."),
        sponsors: anonymize_sponsors(info.sponsors)
    }
  end

  defp anonymize_text(value, _placeholder) when value in [nil, ""], do: value
  defp anonymize_text(_value, placeholder), do: placeholder

  defp anonymize_sponsors(sponsors) when is_list(sponsors) do
    sponsors
    |> Enum.with_index(1)
    |> Enum.map(fn {sponsor, idx} -> anonymize_sponsor(sponsor, idx) end)
  end

  defp anonymize_sponsors(_sponsors), do: []

  defp anonymize_sponsor(sponsor, idx) when is_map(sponsor) do
    sponsor
    |> put_either_key("name", "Sponsor #{idx}")
    |> put_either_key("link", "https://example.invalid/sponsor-#{idx}")
    |> put_either_key("logo_url", "https://example.invalid/sponsor-#{idx}-logo.png")
  end

  defp anonymize_sponsor(sponsor, _idx), do: sponsor

  # Sponsor maps may have string or atom keys depending on how they were
  # decoded; write back using whichever key shape is already present.
  defp put_either_key(map, string_key, value) do
    atom_key = String.to_existing_atom(string_key)

    cond do
      Map.has_key?(map, atom_key) -> Map.put(map, atom_key, value)
      Map.has_key?(map, string_key) -> Map.put(map, string_key, value)
      true -> Map.put(map, string_key, value)
    end
  end

  # Generic id -> placeholder assignment, shared by both the struct-based
  # anonymization above and the payload-based anonymization below.
  #
  # `required?` controls what happens when the current value is blank:
  #   * `true`  (e.g. names) -> always assign a placeholder.
  #   * `false` (e.g. license/signature/username) -> leave blank as-is.
  defp anonymize_field(ctx, map_field, counter_field, id, current_value, formatter, required?) do
    cond do
      not required? and blank?(current_value) ->
        {current_value, ctx}

      is_binary(id) ->
        get_or_put(ctx, map_field, counter_field, id, formatter)

      true ->
        fresh_value(ctx, counter_field, formatter)
    end
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(_), do: false

  defp get_or_put(ctx, map_field, counter_field, id, formatter) do
    existing = Map.fetch!(ctx, map_field)

    case Map.get(existing, id) do
      nil ->
        {value, ctx} = fresh_value(ctx, counter_field, formatter)
        {value, Map.put(ctx, map_field, Map.put(existing, id, value))}

      value ->
        {value, ctx}
    end
  end

  defp fresh_value(ctx, counter_field, formatter) do
    next = Map.fetch!(ctx, counter_field) + 1
    {formatter.(next), Map.put(ctx, counter_field, next)}
  end

  defp pad(n), do: n |> Integer.to_string() |> String.pad_leading(4, "0")

  # --- Event log payload anonymization -------------------------------------

  defp anonymize_event_log_sequence(entries, ctx) do
    Enum.map_reduce(entries, ctx, &anonymize_event_log_entry/2)
  end

  defp anonymize_event_log_entry(
         %{"key" => "add-player-to-team", "payload" => payload} = entry,
         ctx
       ) do
    {payload, ctx} = anonymize_player_payload(payload, ctx)
    {%{entry | "payload" => payload}, ctx}
  end

  defp anonymize_event_log_entry(
         %{"key" => "update-player-in-team", "payload" => %{"player" => player} = payload} =
           entry,
         ctx
       ) do
    {player, ctx} = anonymize_player_payload(player, ctx)
    {%{entry | "payload" => %{payload | "player" => player}}, ctx}
  end

  defp anonymize_event_log_entry(
         %{"key" => "add-coach-to-team", "payload" => payload} = entry,
         ctx
       ) do
    {payload, ctx} = anonymize_coach_payload(payload, ctx)
    {%{entry | "payload" => payload}, ctx}
  end

  defp anonymize_event_log_entry(
         %{"key" => "update-coach-in-team", "payload" => %{"coach" => coach} = payload} = entry,
         ctx
       ) do
    {coach, ctx} = anonymize_coach_payload(coach, ctx)
    {%{entry | "payload" => %{payload | "coach" => coach}}, ctx}
  end

  defp anonymize_event_log_entry(
         %{"key" => "add-official-to-game", "payload" => payload} = entry,
         ctx
       ) do
    {payload, ctx} = anonymize_official_payload(payload, ctx)
    {%{entry | "payload" => payload}, ctx}
  end

  defp anonymize_event_log_entry(
         %{"key" => "update-official-in-game", "payload" => payload} = entry,
         ctx
       ) do
    {payload, ctx} = anonymize_official_payload(payload, ctx)
    {%{entry | "payload" => payload}, ctx}
  end

  defp anonymize_event_log_entry(
         %{"key" => "update-game-info", "payload" => payload} = entry,
         ctx
       ) do
    payload =
      payload
      |> maybe_replace_string_field("location", "Synthetic Location")
      |> maybe_replace_string_field("city", "Synthetic City")
      |> maybe_replace_string_field("game_report", "Synthetic game report.")

    {%{entry | "payload" => payload}, ctx}
  end

  defp anonymize_event_log_entry(entry, ctx), do: {entry, ctx}

  defp anonymize_player_payload(payload, ctx) do
    id = Map.get(payload, "id")

    {payload, ctx} =
      maybe_update(
        payload,
        ctx,
        "name",
        :player_names,
        :player_counter,
        id,
        &"Player #{&1}",
        true
      )

    {payload, ctx} =
      maybe_update(
        payload,
        ctx,
        "license_number",
        :player_licenses,
        :license_counter,
        id,
        &"LICENSE-#{pad(&1)}",
        false
      )

    maybe_update(
      payload,
      ctx,
      "signature",
      :signatures,
      :signature_counter,
      id,
      &"SIGNATURE-#{pad(&1)}",
      false
    )
  end

  defp anonymize_coach_payload(payload, ctx) do
    id = Map.get(payload, "id")

    {payload, ctx} =
      maybe_update(payload, ctx, "name", :coach_names, :coach_counter, id, &"Coach #{&1}", true)

    maybe_update(
      payload,
      ctx,
      "signature",
      :signatures,
      :signature_counter,
      id,
      &"SIGNATURE-#{pad(&1)}",
      false
    )
  end

  defp anonymize_official_payload(payload, ctx) do
    id = Map.get(payload, "id")

    {payload, ctx} =
      maybe_update(
        payload,
        ctx,
        "name",
        :official_names,
        :official_counter,
        id,
        &"Official #{&1}",
        true
      )

    {payload, ctx} =
      maybe_update(
        payload,
        ctx,
        "license_number",
        :official_licenses,
        :official_license_counter,
        id,
        &"OFFICIAL-LICENSE-#{pad(&1)}",
        false
      )

    {payload, ctx} =
      maybe_update(
        payload,
        ctx,
        "signature",
        :signatures,
        :signature_counter,
        id,
        &"SIGNATURE-#{pad(&1)}",
        false
      )

    maybe_update(
      payload,
      ctx,
      "username",
      :official_usernames,
      :username_counter,
      id,
      &"official#{&1}",
      false
    )
  end

  defp maybe_update(payload, ctx, field, map_field, counter_field, id, formatter, required?) do
    if Map.has_key?(payload, field) do
      current = Map.get(payload, field)

      {value, ctx} =
        anonymize_field(ctx, map_field, counter_field, id, current, formatter, required?)

      {Map.put(payload, field, value), ctx}
    else
      {payload, ctx}
    end
  end

  defp maybe_replace_string_field(payload, field, placeholder) do
    case Map.get(payload, field) do
      value when is_binary(value) and value != "" -> Map.put(payload, field, placeholder)
      _ -> payload
    end
  end
end
