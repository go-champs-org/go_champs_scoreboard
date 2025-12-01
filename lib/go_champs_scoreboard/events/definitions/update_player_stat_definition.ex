defmodule GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Sports.Sports
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Teams
  alias GoChampsScoreboard.Games.Players
  alias GoChampsScoreboard.Events.Models.StreamConfig

  @key "update-player-stat"

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
          clock_state_period_at: period,
          payload: %{
            "operation" => op,
            "stat-id" => stat_id,
            "player-id" => player_id,
            "team-type" => team_type
          }
        }
      ) do
    player_stat =
      current_game.sport_id
      |> Sports.find_player_stat(stat_id)

    calculated_player_stats =
      current_game.sport_id
      |> Sports.find_calculated_player_stats()

    calculated_team_stats =
      current_game.sport_id
      |> Sports.find_calculated_team_stats()

    updated_player =
      current_game
      |> Teams.find_player(team_type, player_id)
      |> Players.update_manual_stats_values(player_stat, op)
      |> Players.update_calculated_stats_values(calculated_player_stats)

    updated_team =
      current_game
      |> Teams.find_team(team_type)
      |> Teams.update_player_in_team(updated_player)
      |> Teams.calculate_team_total_player_stats()
      |> Teams.update_calculated_stats_values(calculated_team_stats)
      |> Teams.calculate_period_stats(period)

    current_game
    |> Games.update_team(team_type, updated_team)
  end

  @impl true
  @spec stream_config() :: StreamConfig.t()
  def stream_config, do: StreamConfig.new()
end
