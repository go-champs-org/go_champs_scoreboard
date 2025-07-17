defmodule GoChampsScoreboard.Events.Definitions.UpdateOfficialInGameDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-official-in-game"

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
    official_id = Map.get(payload, "id")

    case find_official_by_id(game_state, official_id) do
      nil ->
        # Official not found, return unchanged game state
        game_state

      existing_official ->
        updated_official = update_official_properties(existing_official, payload)

        game_state
        |> Games.update_official(updated_official)
    end
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  # Private helper functions

  defp find_official_by_id(game_state, official_id) do
    Enum.find(game_state.officials, fn official -> official.id == official_id end)
  end

  defp update_official_properties(existing_official, payload) do
    %OfficialState{
      id: existing_official.id,
      name: get_updated_value(payload, "name", existing_official.name),
      type: get_updated_type(payload, "type", existing_official.type),
      license_number:
        get_updated_value(payload, "license_number", existing_official.license_number),
      federation: get_updated_value(payload, "federation", existing_official.federation)
    }
  end

  defp get_updated_value(payload, key, current_value) do
    case Map.get(payload, key) do
      nil -> current_value
      new_value -> new_value
    end
  end

  defp get_updated_type(payload, key, current_type) do
    case Map.get(payload, key) do
      nil -> current_type
      new_type when is_binary(new_type) -> String.to_existing_atom(new_type)
      new_type when is_atom(new_type) -> new_type
    end
  end
end
