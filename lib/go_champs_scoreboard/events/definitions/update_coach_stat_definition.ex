defmodule GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Sports.Sports
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Games.Coaches
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-coach-stat"

  @impl true
  @spec key() :: String.t()
  def key, do: @key

  @impl true
  @spec validate(game_state :: GameState.t(), payload :: any()) ::
          {:ok} | {:error, any()}
  def validate(_game_state, _paylod), do: {:ok}

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
  def handle(
        current_game,
        %Event{
          payload: %{
            "operation" => op,
            "stat-id" => stat_id,
            "coach-id" => coach_id,
            "team-type" => team_type
          }
        }
      ) do
    coach_stat =
      current_game.sport_id
      |> Sports.find_coach_stat(stat_id)

    calculated_coach_stats =
      current_game.sport_id
      |> Sports.find_calculated_coach_stats()

    updated_coach =
      current_game
      |> Teams.find_coach(team_type, coach_id)
      |> Coaches.update_manual_stats_values(coach_stat, op)
      |> Coaches.update_calculated_stats_values(calculated_coach_stats)

    updated_team =
      current_game
      |> Teams.find_team(team_type)
      |> Teams.update_coach_in_team(updated_coach)

    current_game
    |> Games.update_team(team_type, updated_team)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
