defmodule GoChampsScoreboard.Games.Bootstrapper do
  alias GoChampsScoreboard.Games.Models.LiveState
  alias GoChampsScoreboard.ApiClient
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.ViewSettingsState
  alias GoChampsScoreboard.Games.Models.InfoState
  alias GoChampsScoreboard.Games.Models.ProtestState

  @mock_initial_period_time 600
  @mock_initial_extra_period_time 300

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

    clock_state = map_clock_state(view_settings_data["data"])

    live_state = map_live_state(game_response["live_state"])

    view_settings_state = map_view_settings_state(view_settings_data["data"])

    info = map_info_state(game_response)

    GameState.new(
      game_id,
      away_team,
      home_team,
      clock_state,
      live_state,
      "basketball",
      view_settings_state,
      [],
      ProtestState.new("", "", :no_protest),
      info
    )
  end

  defp map_api_team_to_team(team) do
    name = Map.get(team, "name", "No team")
    logo_url = Map.get(team, "logo_url", "")
    tri_code = Map.get(team, "tri_code", "")
    players = map_team_players_to_players(team)
    coaches = map_team_coaches_to_coaches(team)

    TeamState.new(
      name,
      players,
      %{},
      nil,
      tri_code,
      logo_url,
      coaches
    )
  end

  defp map_team_players_to_players(team) do
    team_players = Map.get(team, "players", [])

    Enum.map(team_players, fn player ->
      name = Map.get(player, "shirt_name") || Map.get(player, "name") || "No name"

      state =
        Map.get(player, "state", "available")
        |> String.to_atom()

      PlayerState.new(player["id"], name, player["shirt_number"], player["license_number"], state)
    end)
  end

  defp map_team_coaches_to_coaches(team) do
    team_coaches = Map.get(team, "coaches", [])

    Enum.map(team_coaches, fn coach ->
      name = Map.get(coach, "name", "No name")
      type = Map.get(coach, "type", "head_coach") |> String.to_atom()
      state = Map.get(coach, "state", "available") |> String.to_atom()

      CoachState.new(
        coach["id"],
        name,
        type,
        state
      )
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

  defp map_clock_state(view_settings_data) do
    case view_settings_data do
      nil ->
        GameClockState.new(
          @mock_initial_period_time,
          @mock_initial_extra_period_time,
          @mock_initial_period_time
        )

      data ->
        initial_period_time = Map.get(data, "initial_period_time", @mock_initial_period_time)

        initial_extra_period_time =
          Map.get(data, "initial_extra_period_time", @mock_initial_extra_period_time)

        GameClockState.new(
          initial_period_time,
          initial_extra_period_time,
          initial_period_time
        )
    end
  end

  defp map_info_state(game_response) do
    datetime_str = Map.get(game_response, "datetime")

    datetime =
      if datetime_str do
        case DateTime.from_iso8601(datetime_str) do
          {:ok, parsed_datetime, _} -> parsed_datetime
          {:error, _} -> DateTime.utc_now()
        end
      else
        nil
      end

    location = Map.get(game_response, "location", "")
    game_id = Map.get(game_response, "id", "")
    tournament_info = get_in(game_response, ["phase", "tournament"]) || %{}
    tournament_id = Map.get(tournament_info, "id", "")
    tournament_name = Map.get(tournament_info, "name", "")
    tournament_slug = Map.get(tournament_info, "slug", "")

    organization_info = Map.get(tournament_info, "organization", %{})
    organization_name = Map.get(organization_info, "name", "")
    organization_slug = Map.get(organization_info, "slug", "")
    organization_logo_url = Map.get(organization_info, "logo_url", "")

    InfoState.new(
      datetime,
      tournament_id: tournament_id,
      tournament_name: tournament_name,
      tournament_slug: tournament_slug,
      organization_name: organization_name,
      organization_slug: organization_slug,
      organization_logo_url: organization_logo_url,
      location: location,
      number: game_id
    )
  end
end
