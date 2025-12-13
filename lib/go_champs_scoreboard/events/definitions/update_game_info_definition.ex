defmodule GoChampsScoreboard.Events.Definitions.UpdateGameInfoDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.InfoState
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Games.Games

  @key "update-game-info"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, payload) do
    with {:ok} <- validate_has_at_least_one_field(payload),
         {:ok} <- validate_location_if_present(payload),
         {:ok} <- validate_number_if_present(payload),
         {:ok} <- validate_game_report_if_present(payload) do
      {:ok}
    else
      error -> error
    end
  end

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
    updated_info = update_info_fields(game_state.info, payload)
    Games.update_info(game_state, updated_info)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  defp validate_has_at_least_one_field(%{} = payload) do
    has_location = Map.has_key?(payload, "location")
    has_number = Map.has_key?(payload, "number")
    has_game_report = Map.has_key?(payload, "game_report")

    if has_location or has_number or has_game_report do
      {:ok}
    else
      {:error, "Must provide at least one field: location, number, or game_report"}
    end
  end

  defp validate_has_at_least_one_field(_payload) do
    {:error, "Must provide at least one field: location, number, or game_report"}
  end

  defp validate_location_if_present(%{"location" => location}) when is_binary(location) do
    {:ok}
  end

  defp validate_location_if_present(%{"location" => _location}) do
    {:error, "Invalid location. Must be a string"}
  end

  defp validate_location_if_present(_payload) do
    {:ok}
  end

  defp validate_number_if_present(%{"number" => number}) when is_binary(number) do
    {:ok}
  end

  defp validate_number_if_present(%{"number" => _number}) do
    {:error, "Invalid number. Must be a string"}
  end

  defp validate_number_if_present(_payload) do
    {:ok}
  end

  defp validate_game_report_if_present(%{"game_report" => game_report})
       when is_binary(game_report) do
    {:ok}
  end

  defp validate_game_report_if_present(%{"game_report" => _game_report}) do
    {:error, "Invalid game_report. Must be a string"}
  end

  defp validate_game_report_if_present(_payload) do
    {:ok}
  end

  defp update_info_fields(current_info, payload) do
    current_info
    |> update_location_if_present(payload)
    |> update_number_if_present(payload)
    |> update_game_report_if_present(payload)
  end

  defp update_location_if_present(info, %{"location" => location}) do
    %InfoState{info | location: location}
  end

  defp update_location_if_present(info, _payload), do: info

  defp update_number_if_present(info, %{"number" => number}) do
    %InfoState{info | number: number}
  end

  defp update_number_if_present(info, _payload), do: info

  defp update_game_report_if_present(info, %{"game_report" => game_report}) do
    %InfoState{info | game_report: game_report}
  end

  defp update_game_report_if_present(info, _payload), do: info
end
