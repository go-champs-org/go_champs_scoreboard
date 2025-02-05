defmodule GoChampsScoreboard.Events.Definitions.GameTickDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Sports.Sports
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "game-tick"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, _paylod), do: {:ok}

  @impl true
  @spec create(game_id :: String.t(), payload :: any()) :: Event.t()
  def create(game_id, _payload), do: Event.new(@key, game_id, nil, true)

  @impl true
  @spec handle(game_state :: GameState.t(), event :: Event.t()) :: GameState.t()
  def handle(game_state, _event \\ nil) do
    new_clock_state =
      game_state.sport_id
      |> Sports.tick(game_state.clock_state)

    game_state
    |> Games.update_clock_state(new_clock_state)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
