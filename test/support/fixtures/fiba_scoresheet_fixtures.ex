defmodule GoChampsScoreboard.FibaScoresheetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  FIBA scoresheet data structures.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

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
    team_b_name = Keyword.get(opts, :team_b_name, "Team B")
    team_b_running_score = Keyword.get(opts, :team_b_running_score, %{})
    team_b_players = Keyword.get(opts, :team_b_players, [])

    %FibaScoresheet{
      game_id: game_id,
      tournament_name: tournament_name,
      header: %FibaScoresheet.Header{},
      team_a: %FibaScoresheet.Team{
        name: team_a_name,
        running_score: team_a_running_score,
        players: team_a_players,
        score: 0,
        all_fouls: [],
        timeouts: []
      },
      team_b: %FibaScoresheet.Team{
        name: team_b_name,
        running_score: team_b_running_score,
        players: team_b_players,
        score: 0,
        all_fouls: [],
        timeouts: []
      }
    }
  end
end
