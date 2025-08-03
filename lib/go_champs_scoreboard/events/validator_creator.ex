defmodule GoChampsScoreboard.Events.ValidatorCreator do
  alias GoChampsScoreboard.Events.Definitions.Registry
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.GameStateCache

  @spec validate_and_create(String.t(), String.t()) :: {:ok, Event.t()} | {:error, any()}
  @spec validate_and_create(String.t(), String.t(), any()) :: {:ok, Event.t()} | {:error, any()}
  def validate_and_create(key, game_id, payload \\ nil) do
    case Registry.get_definition(key) do
      {:ok, definition} ->
        {:ok, game_state} = GameStateCache.get(game_id)

        case game_state
             |> definition.validate(payload) do
          {:ok} ->
            {:ok,
             definition.create(
               game_id,
               game_state.clock_state.time,
               game_state.clock_state.period,
               payload
             )}

          {:error, error} ->
            {:error, error}
        end

      {:error, :not_registered} ->
        {:error, "Event definition not registered for key: #{key}"}
    end
  end

  @spec create(String.t(), String.t(), integer(), integer(), any()) ::
          {:ok, Event.t()}
  def create(key, game_id, clock_time, clock_period, payload) do
    case Registry.get_definition(key) do
      {:ok, definition} ->
        {:ok,
         definition.create(
           game_id,
           clock_time,
           clock_period,
           payload
         )}

      {:error, :not_registered} ->
        {:error, "Event definition not registered for key: #{key}"}
    end
  end
end
