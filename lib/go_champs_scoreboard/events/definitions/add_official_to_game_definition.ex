defmodule GoChampsScoreboard.Events.Definitions.AddOfficialToGameDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Officials
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "add-official-to-game"

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
  def handle(game_state, %Event{
        payload: %{"name" => name, "type" => type} = payload
      }) do
    license_number = Map.get(payload, "license_number")
    federation = Map.get(payload, "federation")

    official = Officials.bootstrap(name, type, license_number, federation)

    game_state
    |> Games.add_official(official)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
