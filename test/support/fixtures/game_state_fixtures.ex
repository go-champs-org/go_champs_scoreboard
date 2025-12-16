defmodule GoChampsScoreboard.GameStateFixtures do
  alias GoChampsScoreboard.Games.Models.{
    GameState,
    TeamState,
    GameClockState,
    LiveState,
    OfficialState,
    ViewSettingsState,
    InfoState,
    PlayerState,
    CoachState,
    ProtestState
  }

  alias GoChampsScoreboard.Sports.Basketball.Basketball

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

    home_coaches = Keyword.get(opts, :home_coaches, [])
    away_coaches = Keyword.get(opts, :away_coaches, [])

    # Create base teams
    home_team = TeamState.new(home_team_name)
    away_team = TeamState.new(away_team_name)

    # Add players and calculate team totals
    home_team = add_players_to_team(home_team, home_players)
    home_team = add_coaches_to_team(home_team, home_coaches)
    away_team = add_players_to_team(away_team, away_players)
    away_team = add_coaches_to_team(away_team, away_coaches)

    clock_state = Keyword.get(opts, :clock_state, GameClockState.new())
    live_state = Keyword.get(opts, :live_state, LiveState.new())
    officials = Keyword.get(opts, :officials, [])
    view_settings_state = Keyword.get(opts, :view_settings_state, ViewSettingsState.new())
    info_state = Keyword.get(opts, :info_state, InfoState.new(DateTime.utc_now()))
    protest_state = Keyword.get(opts, :protest_state, ProtestState.new("", "", :no_protest))

    # Create the game state

    GameState.new(
      game_id,
      away_team,
      home_team,
      clock_state,
      live_state,
      sport_id,
      view_settings_state,
      officials,
      protest_state,
      info_state
    )
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

  defp add_coaches_to_team(team, coaches) do
    # Update team with coaches
    updated_coaches =
      Enum.map(coaches, fn coach ->
        %{
          id: Map.get(coach, :id, ""),
          name: Map.get(coach, :name, ""),
          type: Map.get(coach, :type, :head_coach),
          stats_values: Map.get(coach, :stats_values, %{})
        }
      end)

    Map.put(team, :coaches, updated_coaches)
  end

  @doc """
  Creates a basketball game state with predefined player stats matching the example.
  """
  def basketball_game_state_fixture(opts \\ []) do
    game_id = Keyword.get(opts, :game_id, Ecto.UUID.generate())

    {:ok, datetime, _} =
      "2023-10-01T12:00:00Z"
      |> DateTime.from_iso8601()

    # 1 hour later
    started_at = DateTime.add(datetime, 60 * 60)
    # 1 hour after that
    finished_at = DateTime.add(started_at, 60 * 60)

    game_state_with_players_fixture(
      game_id: game_id,
      sport_id: "basketball",
      clock_state:
        Keyword.get(opts, :clock_state, %GameClockState{
          time: 0,
          period: 4,
          state: :finished,
          initial_period_time: 600,
          initial_extra_period_time: 300,
          started_at: started_at,
          finished_at: finished_at
        }),
      home_players: [
        %PlayerState{
          id: "123",
          name: "Player 1",
          number: 12,
          stats_values: %{
            "fouls_personal" => 0,
            "fouls_technical" => 0,
            "fouls_unsportsmanlike" => 0,
            "fouls_disqualifying" => 0,
            "fouls_game_disqualifying" => 0,
            "free_throws_made" => 0,
            "three_point_field_goals_made" => 0,
            "field_goals_made" => 0,
            "points" => 0,
            "rebounds_defensive" => 0,
            "game_played" => 0,
            "game_started" => 0
          },
          state: :available
        },
        %PlayerState{
          id: "124",
          name: "Player 2",
          number: 23,
          stats_values: %{
            "fouls_personal" => 0,
            "fouls_technical" => 0,
            "fouls_unsportsmanlike" => 0,
            "fouls_disqualifying" => 0,
            "fouls_game_disqualifying" => 0,
            "free_throws_made" => 0,
            "three_point_field_goals_made" => 0,
            "field_goals_made" => 0,
            "points" => 0,
            "rebounds_defensive" => 0,
            "game_played" => 0,
            "game_started" => 0
          },
          state: :available
        }
      ],
      home_coaches: [
        %CoachState{
          id: "coach-id",
          name: "First coach",
          type: :head_coach,
          state: :available,
          stats_values: Basketball.bootstrap_coach_stats()
        },
        %CoachState{
          id: "assistant-coach-id",
          name: "Assistant coach",
          type: :assistant_coach,
          state: :available,
          stats_values: Basketball.bootstrap_coach_stats()
        }
      ],
      away_players: [
        %PlayerState{
          id: "456",
          name: "Player 2",
          number: 23,
          stats_values: %{
            "fouls_personal" => 0,
            "fouls_technical" => 0,
            "fouls_unsportsmanlike" => 0,
            "fouls_disqualifying" => 0,
            "fouls_game_disqualifying" => 0,
            "free_throws_made" => 0,
            "three_point_field_goals_made" => 0,
            "field_goals_made" => 0,
            "points" => 0,
            "rebounds_defensive" => 0,
            "game_played" => 0,
            "game_started" => 0
          },
          state: :available
        }
      ],
      away_coaches: [
        %CoachState{
          id: "away-coach-id",
          name: "Away coach",
          type: :head_coach,
          state: :available,
          stats_values: Basketball.bootstrap_coach_stats()
        },
        %CoachState{
          id: "away-assistant-coach-id",
          name: "Away assistant coach",
          type: :assistant_coach,
          state: :available,
          stats_values: Basketball.bootstrap_coach_stats()
        }
      ],
      officials: [
        %OfficialState{
          id: "scorer-official-id",
          name: "John Scorer",
          type: :scorer,
          license_number: "SC001",
          federation: "FIBA"
        },
        %OfficialState{
          id: "assistant-scorer-official-id",
          name: "Jane Assistant Scorer",
          type: :assistant_scorer,
          license_number: "AS001",
          federation: "FIBA"
        },
        %OfficialState{
          id: "timekeeper-official-id",
          name: "Mike Timekeeper",
          type: :timekeeper,
          license_number: "TK001",
          federation: "NBA"
        },
        %OfficialState{
          id: "shot-clock-operator-official-id",
          name: "Sarah Shot Clock",
          type: :shot_clock_operator,
          license_number: "SCO001",
          federation: "NCAA"
        },
        %OfficialState{
          id: "crew-chief-official-id",
          name: "Robert Crew Chief",
          type: :crew_chief,
          license_number: "CC001",
          federation: "NBA"
        },
        %OfficialState{
          id: "umpire-1-official-id",
          name: "David Umpire One",
          type: :umpire_1,
          license_number: "U1001",
          federation: "FIBA"
        },
        %OfficialState{
          id: "umpire-2-official-id",
          name: "Lisa Umpire Two",
          type: :umpire_2,
          license_number: "U2001",
          federation: "FIBA"
        }
      ],
      info_state: %InfoState{
        number: "ABC123",
        location: "Game Location",
        datetime: datetime,
        tournament_name: "Tournament Name",
        tournament_id: "tournament-id",
        game_report: "This is a game report.",
        web_url: "http://example.com/game_report"
      },
      protest_state: %ProtestState{
        team_type: :home,
        player_id: "123",
        state: :protest_filed
      }
    )
  end
end
