defmodule GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "start-game-live-mode"

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
  def create(game_id, clock_state_time_at, clock_state_period_at, _payload),
    do: Event.new(@key, game_id, clock_state_time_at, clock_state_period_at)

  @impl true
  @spec handle(game_state :: GameState.t(), event :: Event.t()) :: GameState.t()
  def handle(
        game_state,
        _event \\ nil
      ) do
    # Update the game state to in progress
    # and set the started_at time
    started_at = DateTime.utc_now()

    %GameState{
      game_state
      | live_state: %{
          game_state.live_state
          | state: :in_progress,
            started_at: started_at
        }
    }
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config do
    StreamConfig.new(true, :generic_game_event_live_mode_builder)
  end
end
