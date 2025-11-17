defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayerInTeamDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-player-in-team"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, _paylod), do: {:ok}

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
  def handle(game_state, %Event{payload: %{"team-type" => team_type, "player" => player}}) do
    player = Map.new(player, fn {k, v} -> {String.to_atom(k), v} end)

    current_player =
      game_state
      |> Teams.find_player(team_type, player.id)

    {final_game_state, updated_player} =
      handle_captain_update(game_state, team_type, current_player, player)

    updated_team =
      final_game_state
      |> Teams.find_team(team_type)
      |> Teams.update_player_in_team(updated_player)

    final_game_state
    |> Games.update_team(team_type, updated_team)
  end

  @spec handle_captain_update(GameState.t(), String.t(), map(), map()) :: {GameState.t(), map()}
  defp handle_captain_update(game_state, team_type, current_player, player_updates) do
    if Map.get(player_updates, :is_captain) == true do
      team = Teams.find_team(game_state, team_type)

      uncaptained_team = %{
        team
        | players: Enum.map(team.players, &Map.put(&1, :is_captain, false))
      }

      game_state_with_uncaptained_team =
        Games.update_team(game_state, team_type, uncaptained_team)

      {game_state_with_uncaptained_team, Map.merge(current_player, player_updates)}
    else
      {game_state, Map.merge(current_player, player_updates)}
    end
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
