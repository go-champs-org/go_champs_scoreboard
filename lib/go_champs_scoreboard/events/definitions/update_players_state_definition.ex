defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayersStateDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.{Games, Teams, Players}
  alias GoChampsScoreboard.Sports.Sports
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-players-state"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(game_state, payload) do
    with {:ok, _team_type} <- validate_team_type(payload),
         {:ok, player_ids} <- validate_player_ids(payload),
         {:ok, _state} <- validate_state(payload),
         {:ok} <- validate_players_exist(game_state, payload["team-type"], player_ids) do
      {:ok}
    else
      error -> error
    end
  end

  @impl true
  @spec create(
          game_id :: String.t(),
          clock_state_time_at :: integer(),
          clock_state_period_at :: integer(),
          payload :: any()
        ) :: Event.t()
  def create(game_id, clock_state_time_at, clock_state_period_at, payload),
    do: Event.new(@key, game_id, clock_state_time_at, clock_state_period_at, payload)

  @impl true
  @spec handle(GameState.t(), Event.t()) :: GameState.t()
  def handle(current_game, %Event{
        clock_state_time_at: clock_state_time_at,
        clock_state_period_at: clock_state_period_at,
        payload: %{
          "team-type" => team_type,
          "player-ids" => player_ids,
          "state" => state
        }
      }) do
    {:ok, new_state} = PlayerState.string_to_state(state)

    current_team = Teams.find_team(current_game, team_type)

    updated_team =
      player_ids
      |> Enum.reduce(current_team, fn player_id, acc_team ->
        player =
          Teams.find_player(current_game, team_type, player_id)
          |> Players.update_state(new_state)

        updated_player =
          case new_state do
            :playing ->
              player
              |> update_playing_stats(current_game, clock_state_time_at, clock_state_period_at)

            _ ->
              player
          end

        Teams.update_player_in_team(acc_team, updated_player)
      end)

    current_game
    |> Games.update_team(team_type, updated_team)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  defp update_playing_stats(player, game_state, clock_state_time_at, clock_state_period_at) do
    game_played_stat = Sports.find_player_stat(game_state.sport_id, "game_played")

    is_game_start =
      clock_state_time_at == game_state.clock_state.initial_period_time and
        clock_state_period_at == 1

    if is_game_start do
      game_started_stat = Sports.find_player_stat(game_state.sport_id, "game_started")

      player
      |> Players.update_manual_stats_values(game_played_stat, "check")
      |> Players.update_manual_stats_values(game_started_stat, "check")
    else
      player
      |> Players.update_manual_stats_values(game_played_stat, "check")
    end
  end

  defp validate_team_type(%{"team-type" => team_type}) when team_type in ["home", "away"] do
    {:ok, team_type}
  end

  defp validate_team_type(_payload) do
    {:error, "Invalid or missing team-type. Must be 'home' or 'away'"}
  end

  defp validate_player_ids(%{"player-ids" => player_ids})
       when is_list(player_ids) and length(player_ids) > 0 do
    if Enum.all?(player_ids, &is_binary/1) do
      {:ok, player_ids}
    else
      {:error, "All player-ids must be strings"}
    end
  end

  defp validate_player_ids(_payload) do
    {:error, "Invalid or missing player-ids. Must be a non-empty list of strings"}
  end

  defp validate_state(%{"state" => state}) when is_binary(state) do
    if PlayerState.valid_state_string?(state) do
      {:ok, state}
    else
      valid_states = PlayerState.valid_states() |> Enum.map(&Atom.to_string/1) |> Enum.join(", ")
      {:error, "Invalid state. Must be one of: #{valid_states}"}
    end
  end

  defp validate_state(_payload) do
    valid_states = PlayerState.valid_states() |> Enum.map(&Atom.to_string/1) |> Enum.join(", ")
    {:error, "Invalid or missing state. Must be one of: #{valid_states}"}
  end

  defp validate_players_exist(game_state, team_type, player_ids) do
    team = Teams.find_team(game_state, team_type)
    existing_player_ids = Enum.map(team.players, & &1.id)

    invalid_player_ids = player_ids -- existing_player_ids

    if Enum.empty?(invalid_player_ids) do
      {:ok}
    else
      {:error, "Players not found in #{team_type} team: #{Enum.join(invalid_player_ids, ", ")}"}
    end
  end
end
