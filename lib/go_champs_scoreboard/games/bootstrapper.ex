defmodule GoChampsScoreboard.Games.Bootstrapper do
  alias GoChampsScoreboard.ApiClient
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState

  @mock_initial_period_time 600

  @spec bootstrap() :: GameState.t()
  def bootstrap() do
    home_team = TeamState.new("Home team")
    away_team = TeamState.new("Away team")
    clock_state = GameClockState.new()
    game_id = Ecto.UUID.generate()

    GameState.new(game_id, away_team, home_team, clock_state)
  end

  def bootstrap_from_go_champs(game, game_id, token) do
    {:ok, game_response} = ApiClient.get_game(game_id, token)

    game
    |> map_game_response_to_game(game_response)
  end

  defp map_game_response_to_game(game_state, game_data) do
    game_response = game_data["data"]
    away_team = map_api_team_to_team(game_response["away_team"])
    home_team = map_api_team_to_team(game_response["home_team"])

    game_id = Map.get(game_response, "id", game_state.id)

    clock_state = GameClockState.new(@mock_initial_period_time, @mock_initial_period_time)

    GameState.new(game_id, away_team, home_team, clock_state)
  end

  defp map_api_team_to_team(team) do
    name = Map.get(team, "name", "No team")
    players = map_team_players_to_players(team)

    TeamState.new(name, players)
  end

  defp map_team_players_to_players(team) do
    team_players = Map.get(team, "players", [])

    Enum.map(team_players, fn player ->
      PlayerState.new(player["id"], player["name"], player["number"])
    end)
  end
end
