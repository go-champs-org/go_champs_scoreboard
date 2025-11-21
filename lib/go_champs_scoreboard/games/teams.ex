defmodule GoChampsScoreboard.Games.Teams do
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Statistics.Operations
  alias GoChampsScoreboard.Statistics.Models.Stat

  @spec add_coach(GameState.t(), String.t(), CoachState.t()) :: GameState.t()
  def add_coach(game_state, team_type, coach) do
    case team_type do
      "home" ->
        game_state
        |> Map.update!(:home_team, fn team -> add_coach_to_team(team, coach) end)

      "away" ->
        game_state
        |> Map.update!(:away_team, fn team -> add_coach_to_team(team, coach) end)

      _ ->
        raise RuntimeError, message: "Invalid team type"
    end
  end

  @spec add_player(GameState.t(), String.t(), PlayerState.t()) :: GameState.t()
  def add_player(game_state, team_type, player) do
    case team_type do
      "home" ->
        game_state
        |> Map.update!(:home_team, fn team -> add_player_to_team(team, player) end)

      "away" ->
        game_state
        |> Map.update!(:away_team, fn team -> add_player_to_team(team, player) end)

      _ ->
        raise RuntimeError, message: "Invalid team type"
    end
  end

  @spec add_coach_to_team(TeamState.t(), CoachState.t()) :: TeamState.t()
  def add_coach_to_team(team, coach) do
    team
    |> Map.update!(:coaches, fn coaches -> [coach | coaches] end)
  end

  @spec add_player_to_team(TeamState.t(), PlayerState.t()) :: TeamState.t()
  def add_player_to_team(team, player) do
    team
    |> Map.update!(:players, fn players -> [player | players] end)
  end

  @spec find_coach(GameState.t(), String.t(), String.t()) :: CoachState.t()
  def find_coach(game_state, team_type, coach_id) do
    find_team(game_state, team_type)
    |> Map.get(:coaches)
    |> Enum.find(fn coach -> coach.id == coach_id end)
  end

  @spec find_player(GameState.t(), String.t(), String.t()) :: PlayerState.t()
  def find_player(game_state, team_type, player_id) do
    find_team(game_state, team_type)
    |> Map.get(:players)
    |> Enum.find(fn player -> player.id == player_id end)
  end

  @spec find_players(GameState.t(), String.t()) :: [PlayerState.t()]
  def find_players(game_state, team_type) do
    find_team(game_state, team_type).players
  end

  @spec find_team(GameState.t(), String.t()) :: TeamState.t()
  def find_team(game_state, team_type) do
    case team_type do
      "home" -> game_state.home_team
      "away" -> game_state.away_team
      _ -> raise RuntimeError, message: "Invalid team type"
    end
  end

  @spec remove_coach(GameState.t(), String.t(), String.t()) :: GameState.t()
  def remove_coach(game_state, team_type, coach_id) do
    case team_type do
      "home" ->
        game_state
        |> Map.update!(:home_team, fn team -> remove_coach_in_team(team, coach_id) end)

      "away" ->
        game_state
        |> Map.update!(:away_team, fn team -> remove_coach_in_team(team, coach_id) end)

      _ ->
        raise RuntimeError, message: "Invalid team type"
    end
  end

  @spec remove_coach_in_team(TeamState.t(), String.t()) :: CoachState.t()
  def remove_coach_in_team(team, coach_id) do
    team
    |> Map.update!(:coaches, fn coaches ->
      Enum.reject(coaches, fn coach -> coach.id == coach_id end)
    end)
  end

  @spec remove_player(GameState.t(), String.t(), String.t()) :: GameState.t()
  def remove_player(game_state, team_type, player_id) do
    case team_type do
      "home" ->
        game_state
        |> Map.update!(:home_team, fn team -> remove_player_in_team(team, player_id) end)

      "away" ->
        game_state
        |> Map.update!(:away_team, fn team -> remove_player_in_team(team, player_id) end)

      _ ->
        raise RuntimeError, message: "Invalid team type"
    end
  end

  @spec remove_player_in_team(TeamState.t(), String.t()) :: TeamState.t()
  def remove_player_in_team(team, player_id) do
    team
    |> Map.update!(:players, fn players ->
      Enum.reject(players, fn player -> player.id == player_id end)
    end)
  end

  @spec calculate_team_total_player_stats(TeamState.t()) :: TeamState.t()
  def calculate_team_total_player_stats(team) do
    team
    |> Map.update!(:total_player_stats, fn _ ->
      Enum.reduce(team.players, %{}, fn player, acc ->
        Map.merge(acc, player.stats_values, fn _key, acc_key_value, player_key_value ->
          acc_key_value + player_key_value
        end)
      end)
    end)
  end

  @spec update_manual_stats_values(TeamState.t(), Stat.t(), String.t()) :: TeamState.t()
  def update_manual_stats_values(team_state, team_stat, operation) do
    new_stat_value =
      Map.fetch!(team_state.stats_values, team_stat.key)
      |> Operations.calc(operation)

    team_state
    |> update_stats_values(team_stat, new_stat_value)
  end

  @spec update_coach_in_team(TeamState.t(), CoachState.t()) :: TeamState.t()
  def update_coach_in_team(team, coach) do
    team
    |> Map.update!(:coaches, fn coaches ->
      Enum.map(coaches, fn c -> if c.id == coach.id, do: coach, else: c end)
    end)
  end

  @spec update_player_in_team(TeamState.t(), PlayerState.t()) :: TeamState.t()
  def update_player_in_team(team, player) do
    team
    |> Map.update!(:players, fn players ->
      Enum.map(players, fn p -> if p.id == player.id, do: player, else: p end)
    end)
  end

  @spec update_calculated_stats_values(TeamState.t(), [Stat.t()]) :: TeamState.t()
  def update_calculated_stats_values(team_state, stats) do
    stats
    |> Enum.reduce(team_state, fn
      stat, current_team_state ->
        update_calculated_stat_value(current_team_state, stat)
    end)
  end

  @spec update_calculated_stat_value(TeamState.t(), Stat.t()) :: TeamState.t()
  defp update_calculated_stat_value(team_state, stat) do
    new_stat_value =
      team_state
      |> stat.calculation_function.()

    team_state
    |> update_stats_values(stat, new_stat_value)
  end

  @spec update_stats_values(TeamState.t(), Stat.t(), number()) :: TeamState.t()
  defp update_stats_values(team_state, stat, new_value) do
    %{
      team_state
      | stats_values: Map.replace(team_state.stats_values, stat.key, new_value)
    }
  end

  @spec calculate_period_stats(TeamState.t(), integer()) :: TeamState.t()
  def calculate_period_stats(team, current_period) do
    # Convert current_period to string for consistent key format
    current_period_key = to_string(current_period)

    # Use team stats_values for calculation (timeouts, fouls_technical, etc.)
    current_totals = team.stats_values
    existing_periods = team.period_stats || %{}

    # Calculate what the totals were at the END of previous periods
    # Handle both string and integer period keys for backward compatibility
    previous_periods_total =
      existing_periods
      |> Enum.filter(fn {period_key, _stats} ->
        period_int =
          case period_key do
            key when is_integer(key) -> key
            key when is_binary(key) -> String.to_integer(key)
          end

        period_int < current_period
      end)
      |> Enum.reduce(%{}, fn {_period, stats}, acc ->
        Map.merge(acc, stats, fn _key, v1, v2 -> v1 + v2 end)
      end)

    # Current period stats = Current totals - Previous totals
    current_period_stats =
      Map.merge(current_totals, previous_periods_total, fn _key, current, previous ->
        current - previous
      end)

    # Update period_stats with the new period using string key
    updated_period_stats = Map.put(existing_periods, current_period_key, current_period_stats)

    %{team | period_stats: updated_period_stats}
  end
end
