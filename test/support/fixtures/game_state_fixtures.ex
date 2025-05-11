defmodule GoChampsScoreboard.GameStateFixtures do
  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, GameClockState, LiveState}

  @doc """
  Creates a default game state fixture for testing purposes.

  ## Options
    * `:game_id` - The ID of the game (default: "some-game-id")
    * `:away_team_name` - Name of the away team (default: "Some away team")
    * `:home_team_name` - Name of the home team (default: "Some home team")
    * `:clock_state` - Custom clock state (default: new clock state)
    * `:live_state` - Custom live state (default: new live state)

  ## Example
      game_state = create_game_state()
      game_state = create_game_state(game_id: "custom-id", home_team_name: "Lakers")
  """
  def game_state_fixture(opts \\ []) do
    game_id = Keyword.get(opts, :game_id, Ecto.UUID.generate())
    away_team_name = Keyword.get(opts, :away_team_name, "Some away team")
    home_team_name = Keyword.get(opts, :home_team_name, "Some home team")

    away_team = TeamState.new(away_team_name)
    home_team = TeamState.new(home_team_name)
    clock_state = Keyword.get(opts, :clock_state, GameClockState.new())
    live_state = Keyword.get(opts, :live_state, LiveState.new())

    GameState.new(game_id, away_team, home_team, clock_state, live_state)
  end

  @doc """
  Creates a game state with players and statistics.

  ## Options
    * `:game_id` - The ID of the game (default: "some-game-id")
    * `:sport_id` - Sport identifier (default: "basketball")
    * `:home_team_name` - Name of the home team (default: "Some home team")
    * `:away_team_name` - Name of the away team (default: "Some away team")
    * `:home_players` - List of home team players with their stats (default: see example)
    * `:away_players` - List of away team players with their stats (default: [%{id: "456", stats_values: %{}}])
    * `:clock_state` - Custom clock state (default: new clock state)
    * `:live_state` - Custom live state (default: new live state)

  ## Example
      game_state_with_players_fixture()

      # With custom players
      game_state_with_players_fixture(
        home_players: [
          %{id: "123", stats_values: %{"points" => 10, "rebounds" => 5}}
        ],
        away_players: [
          %{id: "456", stats_values: %{"points" => 8}}
        ]
      )
  """
  def game_state_with_players_fixture(opts \\ []) do
    game_id = Keyword.get(opts, :game_id, Ecto.UUID.generate())
    sport_id = Keyword.get(opts, :sport_id, "basketball")
    home_team_name = Keyword.get(opts, :home_team_name, "Some home team")
    away_team_name = Keyword.get(opts, :away_team_name, "Some away team")

    default_home_players = [
      %{
        id: "123",
        stats_values: %{
          "field_goals_made" => 0,
          "free_throws_made" => 0,
          "points" => 0,
          "rebounds_defensive" => 0,
          "three_point_field_goals_made" => 0
        }
      }
    ]

    default_away_players = [
      %{id: "456", stats_values: %{}}
    ]

    home_players = Keyword.get(opts, :home_players, default_home_players)
    away_players = Keyword.get(opts, :away_players, default_away_players)

    # Create base teams
    home_team = TeamState.new(home_team_name)
    away_team = TeamState.new(away_team_name)

    # Add players and calculate team totals
    home_team = add_players_to_team(home_team, home_players)
    away_team = add_players_to_team(away_team, away_players)

    clock_state = Keyword.get(opts, :clock_state, GameClockState.new())
    live_state = Keyword.get(opts, :live_state, LiveState.new())

    # Create the game state
    base_state = GameState.new(game_id, away_team, home_team, clock_state, live_state)

    # Add sport_id
    Map.put(base_state, :sport_id, sport_id)
  end

  defp add_players_to_team(team, players) do
    # Update team with players and total stats
    total_player_stats =
      players
      |> Enum.reduce(%{}, fn player, acc ->
        player_stats = Map.get(player, :stats_values, %{})
        Map.merge(acc, player_stats, fn _key, val1, val2 -> val1 + val2 end)
      end)

    team
    |> Map.put(:players, players)
    |> Map.put(:total_player_stats, total_player_stats)
  end

  @doc """
  Creates a basketball game state with predefined player stats matching the example.
  """
  def basketball_game_state_fixture(opts \\ []) do
    game_state_with_players_fixture(
      game_id: Keyword.get(opts, :game_id, Ecto.UUID.generate()),
      sport_id: "basketball",
      home_players: [
        %{
          id: "123",
          name: "Player 1",
          number: 12,
          stats_values: %{
            "fouls_personal" => 0,
            "fouls_technical" => 0,
            "free_throws_made" => 0,
            "three_point_field_goals_made" => 0,
            "field_goals_made" => 0,
            "points" => 0,
            "rebounds_defensive" => 0
          }
        }
      ],
      away_players: [
        %{
          id: "456",
          name: "Player 2",
          number: 23,
          stats_values: %{
            "fouls_personal" => 0,
            "fouls_technical" => 0,
            "free_throws_made" => 0,
            "three_point_field_goals_made" => 0,
            "field_goals_made" => 0,
            "points" => 0,
            "rebounds_defensive" => 0
          }
        }
      ]
    )
  end
end
