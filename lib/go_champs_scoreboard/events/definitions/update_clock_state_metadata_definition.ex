defmodule GoChampsScoreboard.Events.Definitions.UpdateClockStateMetadataDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-clock-state-metadata"

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
  @spec handle(GameState.t(), Event.t()) :: GameState.t()
  def handle(game_state, %Event{payload: payload}) do
    updated_clock_state = update_clock_metadata(game_state.clock_state, payload)

    game_state
    |> Games.update_clock_state(updated_clock_state)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  defp update_clock_metadata(clock_state, payload) do
    clock_state
    |> maybe_update_field(:initial_period_time, payload["initial_period_time"])
    |> maybe_update_field(:initial_extra_period_time, payload["initial_extra_period_time"])
    |> maybe_update_field(:started_at, parse_datetime(payload["started_at"]))
    |> maybe_update_field(:finished_at, parse_datetime(payload["finished_at"]))
  end

  defp maybe_update_field(clock_state, _field, nil), do: clock_state

  defp maybe_update_field(clock_state, field, value) do
    Map.put(clock_state, field, value)
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_string) when is_binary(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> datetime
      {:error, _} -> nil
    end
  end

  defp parse_datetime(datetime), do: datetime
end
