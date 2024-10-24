defmodule GoChampsScoreboard.Games.Bootstrapper do
  alias GoChampsScoreboard.ApiClient
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState

  @mock_home_players [
    PlayerState.new("player-1", "Lair Júnior"),
    PlayerState.new("player-2", "Fausto Silva")
  ]
  @mock_away_players [
    PlayerState.new("player-3", "Ruan Victor"),
    PlayerState.new("player-4", "Gugu Liberato")
  ]
  @mock_initial_period_time 600

  @spec bootstrap() :: GameState.t()
  def bootstrap() do
    home_team = TeamState.new("Home team")
    away_team = TeamState.new("Away team")
    clock_state = GameClockState.new()
    game_id = Ecto.UUID.generate()

    GameState.new(game_id, away_team, home_team, clock_state)
  end

  def bootstrap_from_go_champs(game, game_id) do
    {:ok, game_response} = ApiClient.get_game(game_id)

    game
    |> map_game_response_to_game(game_response)
  end

  defp map_game_response_to_game(game_state, game_data) do
    game_response = game_data["data"]
    away_team_name = Map.get(game_response["away_team"], "name", game_state.away_team.name)
    home_team_name = Map.get(game_response["home_team"], "name", game_state.home_team.name)

    away_team = TeamState.new(away_team_name, @mock_away_players)
    home_team = TeamState.new(home_team_name, @mock_home_players)

    game_id = Map.get(game_response, "id", game_state.id)

    clock_state = GameClockState.new(@mock_initial_period_time, @mock_initial_period_time)

    GameState.new(game_id, away_team, home_team, clock_state)
  end
end
