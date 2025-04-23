defmodule GoChampsScoreboard.Events.Definitions.DefinitionBehavior do
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @callback key() :: String.t()
  @callback validate(game_state :: GameState.t(), payload :: any()) ::
              {:ok} | {:error, any()}
  @callback create(
              game_id :: String.t(),
              clock_state_time_at :: integer(),
              clock_state_period_at :: integer(),
              payload :: any()
            ) :: Event.t()
  @callback handle(GameState.t(), Event.t()) :: GameState.t()
  @callback stream_config() :: StreamConfig.t()
end
