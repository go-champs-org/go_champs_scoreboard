defmodule GoChampsScoreboard.Events.Definitions.LoadFromLastEventLogDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Sports.Sports

  @key "load-from-last-event-log"

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
  def create(game_id, clock_state_time_at, clock_state_period_at, _payload),
    do:
      Event.new(@key, game_id, clock_state_time_at, clock_state_period_at, nil, %{
        persistable: false
      })

  @impl true
  @spec handle(game_state :: GameState.t(), event :: Event.t()) :: GameState.t()
  def handle(game_state, _event) do
    case EventLogs.get_last_by_game_id(game_state.id) do
      nil ->
        game_state

      event_log ->
        case event_log.snapshot do
          nil ->
            game_state

          snapshot ->
            Sports.map_from_snapshot(game_state.sport_id, game_state, snapshot)
        end
    end
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
