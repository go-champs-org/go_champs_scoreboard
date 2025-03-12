defmodule GoChampsScoreboard.Games.Bootstrapper do
  alias GoChampsScoreboard.Games.Models.LiveState
  alias GoChampsScoreboard.ApiClient
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.ViewSettingsState

  @mock_initial_period_time 600

  @spec bootstrap() :: GameState.t()
  def bootstrap() do
    home_team = TeamState.new("Home team")
    away_team = TeamState.new("Away team")
    clock_state = GameClockState.new()
    game_id = Ecto.UUID.generate()
    live_state = LiveState.new()

    GameState.new(game_id, away_team, home_team, clock_state, live_state)
  end

  def bootstrap_from_go_champs(game, game_id, token) do
    {:ok, game_response} = ApiClient.get_game(game_id, token)

    {:ok, view_settings_response} = ApiClient.get_scoreboard_setting(game_id)

    game
    |> map_game_response_to_game(game_response, view_settings_response)
  end

  defp map_game_response_to_game(game_state, game_data, view_settings_data) do
    game_response = game_data["data"]
    away_team = map_api_team_to_team(game_response["away_team"])
    home_team = map_api_team_to_team(game_response["home_team"])

    game_id = Map.get(game_response, "id", game_state.id)

    clock_state = GameClockState.new(@mock_initial_period_time, @mock_initial_period_time)

    live_state = map_live_state(game_response["live_state"])

    view_settings_state = map_view_settings_state(view_settings_data["data"])

    GameState.new(
      game_id,
      away_team,
      home_team,
      clock_state,
      live_state,
      "basketball",
      view_settings_state
    )
  end

  defp map_api_team_to_team(team) do
    name = Map.get(team, "name", "No team")
    players = map_team_players_to_players(team)

    TeamState.new(name, players)
  end

  defp map_team_players_to_players(team) do
    team_players = Map.get(team, "players", [])

    Enum.map(team_players, fn player ->
      name = Map.get(player, "shirt_name") || Map.get(player, "name") || "No name"
      PlayerState.new(player["id"], name, player["shirt_number"], :available)
    end)
  end

  defp map_live_state(live_state) do
    case live_state do
      "not_started" -> LiveState.new(:not_started)
      "in_progress" -> LiveState.new(:in_progress)
      "ended" -> LiveState.new(:ended)
      _ -> LiveState.new(:not_started)
    end
  end

  defp map_view_settings_state(view_settings_data) do
    case view_settings_data do
      nil ->
        ViewSettingsState.new()

      data ->
        view = Map.get(data, "view", "basketball-medium")
        ViewSettingsState.new(view)
    end
  end
end
