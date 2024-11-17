defmodule GoChampsScoreboard.Events.Definitions.AddPlayerToTeamDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Players
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "add-player-to-team"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, _paylod), do: {:ok}

  @impl true
  @spec create(game_id :: String.t(), payload :: any()) :: Event.t()
  def create(game_id, payload), do: Event.new(@key, game_id, payload)

  @impl true
  @spec handle(GameState.t(), Event.t()) :: GameState.t()
  def handle(game_state, %Event{
        payload: %{"name" => name, "number" => number, "team_type" => team_type}
      }) do
    player = Players.bootstrap(name, number)

    game_state
    |> Teams.add_player(team_type, player)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end