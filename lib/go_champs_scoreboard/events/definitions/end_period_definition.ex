defmodule GoChampsScoreboard.Events.Definitions.EndPeriodDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Sports.Sports

  @key "end-period"

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
  @spec handle(
          GameState.t(),
          Event.t()
        ) :: GameState.t()
  @spec handle(any()) :: none()
  def handle(
        game_state,
        _event \\ nil
      ) do
    next_clock_state =
      game_state.sport_id
      |> Sports.end_period(game_state.clock_state)

    game_state
    |> Games.update_clock_state(next_clock_state)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config,
    do: StreamConfig.new()
end
