defmodule GoChampsScoreboard.Events.Definitions.ResetGameLiveModeDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "reset-game-live-mode"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, _paylod), do: {:ok}

  @impl true
  @spec create(game_id :: String.t(), payload :: any()) :: Event.t()
  def create(game_id, _payload), do: Event.new(@key, game_id)

  @impl true
  @spec handle(game_state :: GameState.t(), event :: Event.t()) :: GameState.t()
  def handle(
        game_state,
        _event \\ nil
      ) do
    %{game_state | live_state: %{state: :not_started}}
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config do
    StreamConfig.new(true, :generic_game_event_live_mode_builder)
  end
end
