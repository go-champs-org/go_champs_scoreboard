defmodule GoChampsScoreboard.Events.Definitions.RegisterTeamWODefinition do
  @moduledoc """
  Event definition for registering a team without officials (WO = Without Officials).
  """

  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.StreamConfig
  alias GoChampsScoreboard.Sports.Sports

  @key "register-team-wo"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(GameState.t(), any()) :: {:ok} | {:error, any()}
  def validate(_game_state, _payload), do: {:ok}

  @impl true
  @spec create(String.t(), integer(), integer(), any()) :: Event.t()
  def create(game_id, clock_state_time_at, clock_state_period_at, payload) do
    Event.new(@key, game_id, clock_state_time_at, clock_state_period_at, payload)
  end

  @impl true
  @spec handle(GameState.t(), Event.t()) :: GameState.t()
  def handle(current_game, %Event{payload: payload}) do
    team_type = Map.get(payload, "team-type")

    current_game.sport_id
    |> Sports.register_team_wo(current_game, team_type)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config,
    do: StreamConfig.new()
end
