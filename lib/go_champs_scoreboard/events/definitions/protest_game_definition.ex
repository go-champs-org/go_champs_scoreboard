defmodule GoChampsScoreboard.Events.Definitions.ProtestGameDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Sports.Sports

  @key "protest-game"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, _payload), do: {:ok}

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
  @spec handle(
          GameState.t(),
          Event.t()
        ) :: GameState.t()
  @spec handle(any()) :: none()
  def handle(
        game_state,
        event \\ nil
      ) do
    case event do
      %Event{payload: payload} when payload != nil ->
        game_state.sport_id
        |> Sports.protest_game(game_state, payload)

      _ ->
        game_state
    end
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config,
    do: StreamConfig.new()
end
