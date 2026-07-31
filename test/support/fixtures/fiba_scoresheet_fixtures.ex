defmodule GoChampsScoreboard.FibaScoresheetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  FIBA scoresheet data structures.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  # Shared golden fixture directory for the FIBA scoresheet regression suite
  # (see test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs).
  # Centralized here so any future consumer of these fixtures (a JS PDF
  # rendering suite, a real-game-export regression check, etc.) points at
  # the exact same files instead of re-deriving the path.
  @fixtures_dir Path.expand("../../fixtures/fiba_scoresheet", __DIR__)

  # Real-game captures (from Mix.Tasks.FibaScoresheet.ExportGame) live in
  # their own subdirectory, separate from the hand-built scenario goldens,
  # since they follow a different format (`initial_state` +
  # `event_log_sequence` to be replayed, rather than a golden FibaScoresheet
  # contract to compare against directly).
  @real_games_dir Path.join(@fixtures_dir, "real_games")

  @doc """
  Returns the absolute path to the shared golden fixture directory for FIBA
  scoresheet regression scenarios.
  """
  @spec fixtures_dir() :: String.t()
  def fixtures_dir, do: @fixtures_dir

  @doc """
  Returns the absolute path to a named scenario's golden JSON fixture file,
  e.g. `golden_fixture_path("normal_game")` ->
  `test/fixtures/fiba_scoresheet/normal_game.json`.
  """
  @spec golden_fixture_path(String.t()) :: String.t()
  def golden_fixture_path(scenario_name) do
    Path.join(@fixtures_dir, "#{scenario_name}.json")
  end

  @doc """
  Returns the absolute path to a named real-game capture fixture, e.g.
  `real_game_fixture_path("sample_synthetic_capture")` ->
  `test/fixtures/fiba_scoresheet/real_games/sample_synthetic_capture.json`.

  This is the single place that defines where
  `Mix.Tasks.FibaScoresheet.ExportGame` writes captures and where
  `GoChampsScoreboard.FibaScoresheetScenarios.replay_real_game_fixture!/1`
  reads them back from. Note: the Mix task itself (under `lib/`, compiled in
  every `MIX_ENV`) cannot depend on this test-only module, so it duplicates
  this same path rather than calling into it — see the comment on
  `fixture_output_path/1` in
  `lib/mix/tasks/fiba_scoresheet.export_game.ex`.
  """
  @spec real_game_fixture_path(String.t()) :: String.t()
  def real_game_fixture_path(name) do
    Path.join(@real_games_dir, "#{name}.json")
  end

  @doc """
  Loads and Poison-decodes a named scenario's golden JSON fixture.

  Intended to be compared against a `Poison.encode!/1` + `Poison.decode!/1`
  roundtrip of an actual `Reports.fetch_report_data/2` result, so both sides
  of the comparison go through the same string-keyed JSON shape (avoiding
  brittle struct/atom-vs-string mismatches) and test the actual wire
  contract shape the frontend receives.
  """
  @spec load_golden!(String.t()) :: map()
  def load_golden!(scenario_name) do
    scenario_name
    |> golden_fixture_path()
    |> File.read!()
    |> Poison.decode!()
  end

  @doc """
  Loads and Poison-decodes a named real-game capture's locked expected
  contract (`test/fixtures/fiba_scoresheet/real_games/<name>.expected.json`).

  Analogous to `load_golden!/1`, but for fixtures replayed via
  `GoChampsScoreboard.FibaScoresheetScenarios.replay_real_game_fixture!/1`.
  Unlike a hand-built scenario's golden file (whose correctness is reasoned
  about from the events fed in), this is a regression lock, not a
  correctness proof — there's no independent source of truth for what a
  real captured game's contract "should" be.
  """
  @spec load_real_game_golden!(String.t()) :: map()
  def load_real_game_golden!(name) do
    "#{name}.expected"
    |> real_game_fixture_path()
    |> File.read!()
    |> Poison.decode!()
  end

  @doc """
  Creates a FIBA scoresheet fixture with default values.

  ## Options
    * `:game_id` - The ID of the game (default: "some-game-id")
    * `:tournament_name` - Name of the tournament (default: "Some Tournament")
    * `:team_a_name` - Name of team A (default: "Team A")
    * `:team_b_name` - Name of team B (default: "Team B")

  ## Example
      fiba_scoresheet_fixture()
      fiba_scoresheet_fixture(game_id: "custom-id", tournament_name: "Custom Tournament")
  """
  def fiba_scoresheet_fixture(opts \\ []) do
    game_id = Keyword.get(opts, :game_id, Ecto.UUID.generate())
    tournament_name = Keyword.get(opts, :tournament_name, "Some Tournament")
    team_a_name = Keyword.get(opts, :team_a_name, "Team A")
    team_a_running_score = Keyword.get(opts, :team_a_running_score, %{})
    team_a_players = Keyword.get(opts, :team_a_players, [])

    team_a_coach =
      Keyword.get(opts, :team_a_coach, %FibaScoresheet.Coach{
        id: "home-coach-id",
        name: "Coach 1",
        fouls: []
      })

    team_a_assistant_coach =
      Keyword.get(opts, :team_a_assistant_coach, %FibaScoresheet.Coach{
        id: "home-assistant-coach-id",
        name: "Assistant Coach 1",
        fouls: []
      })

    team_b_name = Keyword.get(opts, :team_b_name, "Team B")
    team_b_running_score = Keyword.get(opts, :team_b_running_score, %{})
    team_b_players = Keyword.get(opts, :team_b_players, [])

    team_b_coach =
      Keyword.get(opts, :team_b_coach, %FibaScoresheet.Coach{
        id: "away-coach-id",
        name: "Coach 2",
        fouls: []
      })

    team_b_assistant_coach =
      Keyword.get(opts, :team_b_assistant_coach, %FibaScoresheet.Coach{
        id: "away-assistant-coach-id",
        name: "Assistant Coach 2",
        fouls: []
      })

    %FibaScoresheet{
      game_id: game_id,
      tournament_name: tournament_name,
      info: %FibaScoresheet.Info{},
      team_a: %FibaScoresheet.Team{
        name: team_a_name,
        running_score: team_a_running_score,
        players: team_a_players,
        score: 0,
        coach: team_a_coach,
        assistant_coach: team_a_assistant_coach,
        all_fouls: [],
        timeouts: [],
        head_coach_challenges: [],
        has_walkover: false,
        points_by_period: %{},
        points_summary: %{}
      },
      team_b: %FibaScoresheet.Team{
        name: team_b_name,
        running_score: team_b_running_score,
        players: team_b_players,
        score: 0,
        coach: team_b_coach,
        assistant_coach: team_b_assistant_coach,
        all_fouls: [],
        timeouts: [],
        head_coach_challenges: [],
        has_walkover: false,
        points_by_period: %{},
        points_summary: %{}
      }
    }
  end
end
