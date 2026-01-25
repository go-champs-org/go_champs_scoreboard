defmodule GoChampsScoreboard.Events.Definitions.UpdateTeamMetadataDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-team-metadata"

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
    team_type = payload["team-type"]

    updated_team =
      game_state
      |> Teams.find_team(team_type)
      |> update_team_metadata(payload)

    game_state
    |> Games.update_team(team_type, updated_team)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()

  defp update_team_metadata(team, payload) do
    team
    |> maybe_update_field(:name, payload["name"])
    |> maybe_update_nullable_field(payload, "tri_code")
    |> maybe_update_nullable_field(payload, "primary_color")
  end

  defp maybe_update_field(team, _field, nil), do: team

  defp maybe_update_field(team, field, value) do
    Map.put(team, field, value)
  end

  defp maybe_update_nullable_field(team, payload, field_string)
       when is_map_key(payload, field_string) do
    field_atom = String.to_atom(field_string)
    value = Map.get(payload, field_string)
    Map.put(team, field_atom, value)
  end

  defp maybe_update_nullable_field(team, _payload, _field_string), do: team
end
