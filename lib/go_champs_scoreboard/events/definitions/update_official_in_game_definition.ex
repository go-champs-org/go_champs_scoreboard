defmodule GoChampsScoreboard.Events.Definitions.UpdateOfficialInGameDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Officials
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

    # Convert type from string to atom if provided
    official_type =
      case Map.get(payload, "type") do
        nil -> nil
        type when is_binary(type) -> String.to_existing_atom(type)
        type when is_atom(type) -> type
      end

    case Officials.find_by_id_and_type(game_state.officials, official_id, official_type) do
      nil ->
        # Official not found, return unchanged game state
        game_state

      existing_official ->
        # Check if a new ID was provided (from tournament official selection)
        new_id = Map.get(payload, "new_id")

        if new_id do
          # Remove old official and add new one with tournament ID
          updated_official =
            update_official_properties_with_new_id(existing_official, payload, new_id)

          game_state
          |> Games.remove_official_by_id_and_type(official_id, official_type)
          |> Games.add_official(updated_official)
        else
          # Keep existing ID and type for manual updates
          updated_official = update_official_properties(existing_official, payload)

          game_state
          |> Games.update_official_by_id_and_type(updated_official)
        end
    end
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  # Private helper functions

  defp update_official_properties(existing_official, payload) do
    %OfficialState{
      id: existing_official.id,
      name: get_updated_value(payload, "name", existing_official.name),
      type: existing_official.type,
      license_number:
        get_updated_value(payload, "license_number", existing_official.license_number),
      federation: get_updated_value(payload, "federation", existing_official.federation),
      signature: get_updated_value(payload, "signature", existing_official.signature),
      username: get_updated_value(payload, "username", existing_official.username)
    }
  end

  defp update_official_properties_with_new_id(existing_official, payload, new_id) do
    %OfficialState{
      # Use tournament official ID
      id: new_id,
      name: get_updated_value(payload, "name", existing_official.name),
      type: existing_official.type,
      license_number:
        get_updated_value(payload, "license_number", existing_official.license_number),
      federation: get_updated_value(payload, "federation", existing_official.federation),
      signature: get_updated_value(payload, "signature", existing_official.signature),
      username: get_updated_value(payload, "username", existing_official.username)
    }
  end

  defp get_updated_value(payload, key, current_value) do
    if Map.has_key?(payload, key) do
      Map.get(payload, key)
    else
      current_value
    end
  end
end
