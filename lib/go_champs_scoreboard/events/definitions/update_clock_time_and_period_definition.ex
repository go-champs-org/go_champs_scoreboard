defmodule GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Statistics.Operations

  @key "update-clock-time-and-period"

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
  def handle(game_state, %Event{payload: %{"property" => property, "operation" => operation}}) do
    property = String.to_atom(property)

    new_property_value =
      Map.fetch!(game_state.clock_state, property)
      |> Operations.calc(operation)
      |> avoid_negative_value()
      |> avoid_greater_than(game_state.clock_state.initial_period_time)

    new_clock_state = Map.replace(game_state.clock_state, property, new_property_value)

    game_state
    |> Games.update_clock_state(new_clock_state)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  defp avoid_negative_value(value) when value < 0, do: 0
  defp avoid_negative_value(value), do: value

  defp avoid_greater_than(value, max_value) when value > max_value, do: max_value
  defp avoid_greater_than(value, _), do: value
end
