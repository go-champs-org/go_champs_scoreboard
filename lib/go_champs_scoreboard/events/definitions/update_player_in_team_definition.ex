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

    updated_player = Map.merge(current_player, player)

    updated_team =
      game_state
      |> Teams.find_team(team_type)
      |> Teams.update_player_in_team(updated_player)

    game_state
    |> Games.update_team(team_type, updated_team)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
