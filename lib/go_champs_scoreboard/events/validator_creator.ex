defmodule GoChampsScoreboard.Events.ValidatorCreator do
  alias GoChampsScoreboard.Events.Definitions.Registry
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Games

  @spec validate_and_create(String.t(), String.t()) :: {:ok, Event.t()} | {:error, any()}
  @spec validate_and_create(String.t(), String.t(), any()) :: {:ok, Event.t()} | {:error, any()}
  def validate_and_create(key, game_id, payload \\ nil) do
    case Registry.get_definition(key) do
      {:ok, definition} ->
        case Games.get_game(game_id)
             |> definition.validate(payload) do
          {:ok} ->
            {:ok, definition.create(game_id, payload)}

          {:error, error} ->
            {:error, error}
        end

      {:error, :not_registered} ->
        {:error, "Event definition not registered for key: #{key}"}
    end
  end
end
