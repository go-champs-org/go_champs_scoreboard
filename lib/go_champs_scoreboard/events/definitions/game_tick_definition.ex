defmodule GoChampsScoreboard.Events.Definitions.GameTickDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Sports.Sports
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "game-tick"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate_and_create(payload :: any()) :: {:ok, Event.t()}
  def validate_and_create(_payload \\ nil), do: {:ok, Event.new(@key)}

  @impl true
  @spec handle(game_state :: GameState.t(), event :: Event.t()) :: GameState.t()
  def handle(game_state, _event \\ nil) do
    new_clock_state =
      game_state.sport_id
      |> Sports.tick(game_state.clock_state)

    game_state
    |> Games.update_clock_state(new_clock_state)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
