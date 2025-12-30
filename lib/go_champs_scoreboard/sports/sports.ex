defmodule GoChampsScoreboard.Sports.Sports do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Sports.Basketball
  alias GoChampsScoreboard.Statistics.Models.Stat
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Events.GameSnapshot

  import Ecto.Query

  @spec bootstrap_officials(String.t()) :: [OfficialState.t()]
  def bootstrap_officials("basketball") do
    Basketball.OfficialState.bootstrap_officials()
  end

  def bootstrap_officials(_sport_id), do: []

  @spec find_player_stat(String.t(), String.t()) :: Stat.t()
  def find_player_stat("basketball", stat_id), do: Basketball.Basketball.find_player_stat(stat_id)

  @spec find_calculated_player_stats(String.t()) :: [Stat.t()]
  def find_calculated_player_stats("basketball"),
    do: Basketball.Basketball.find_calculated_player_stats()

  @spec find_player_stat_by_type(String.t(), [atom()]) :: [Stat.t()]
  def find_player_stat_by_type("basketball", types),
    do: Basketball.Basketball.find_player_stat_by_type(types)

  @spec find_coach_stat(String.t(), String.t()) :: Stat.t()
  def find_coach_stat("basketball", stat_id), do: Basketball.Basketball.find_coach_stat(stat_id)

  @spec find_calculated_coach_stats(String.t()) :: [Stat.t()]
  def find_calculated_coach_stats("basketball"),
    do: Basketball.Basketball.find_calculated_coach_stats()

  @spec find_team_stat(String.t(), String.t()) :: Stat.t()
  def find_team_stat("basketball", stat_id), do: Basketball.Basketball.find_team_stat(stat_id)

  @spec find_calculated_team_stats(String.t()) :: [Stat.t()]
  def find_calculated_team_stats("basketball"),
    do: Basketball.Basketball.find_calculated_team_stats()

  @spec update_player_state(String.t(), PlayerState.t()) :: PlayerState.t()
  def update_player_state("basketball", player),
    do: Basketball.PlayerState.update_player_state(player)

  @spec update_player_state(String.t(), PlayerState.t()) :: PlayerState.t()
  def update_player_state(_, player), do: player

  @spec update_coach_state(String.t(), CoachState.t()) :: CoachState.t()
  def update_coach_state("basketball", coach),
    do: Basketball.CoachState.update_coach_state(coach)

  @spec update_coach_state(String.t(), CoachState.t()) :: CoachState.t()
  def update_coach_state(_, coach), do: coach

  @spec advance_to(String.t(), GameClockState.t(), GameClockState.state()) :: GameClockState.t()
  def advance_to("basketball", clock_state, state) do
    Basketball.GameClock.advance_to(clock_state, state)
  end

  def advance_to(_, clock_state, _state), do: clock_state

  @spec tick(String.t(), GameClockState.t()) :: GameClockState.t()
  def tick("basketball", game_clock_state), do: Basketball.GameClock.tick(game_clock_state)

  @spec player_tick(String.t(), PlayerState.t(), GameClockState.t()) :: PlayerState.t()
  def player_tick("basketball", player, game_clock_state) do
    Basketball.PlayerClock.player_tick(player, game_clock_state)
  end

  @spec end_period(String.t(), GameClockState.t()) :: GameClockState.t()
  def end_period("basketball", game_clock_state) do
    Basketball.GameClock.end_period(game_clock_state)
  end

  def end_period(_, game_clock_state), do: game_clock_state

  @spec start_game(String.t(), GameClockState.t()) :: GameClockState.t()
  def start_game("basketball", game_clock_state) do
    Basketball.GameClock.start_game(game_clock_state)
  end

  def start_game(_, game_clock_state), do: game_clock_state

  @spec end_game(String.t(), GameClockState.t()) :: GameClockState.t()
  def end_game("basketball", game_clock_state) do
    Basketball.GameClock.end_game(game_clock_state)
  end

  def end_game(_, game_clock_state), do: game_clock_state

  @spec event_logs_order_by(String.t(), Ecto.Query.t()) :: Ecto.Query.t()
  def event_logs_order_by("basketball", query) do
    Basketball.EventLogsOperations.order_by(query)
  end

  @spec event_logs_order_by(String.t(), Ecto.Query.t()) :: Ecto.Query.t()
  def event_logs_order_by(_, query) do
    from e in query,
      order_by: [asc: e.timestamp],
      select: e
  end

  @spec event_logs_reverse_order_by(String.t(), Ecto.Query.t()) :: Ecto.Query.t()
  def event_logs_reverse_order_by("basketball", query) do
    Basketball.EventLogsOperations.reverse_order_by(query)
  end

  def event_logs_reverse_order_by(_, query) do
    from e in query,
      order_by: [desc: e.timestamp],
      select: e
  end

  @spec event_logs_where_type_is_undoable(String.t(), Ecto.Query.t()) :: Ecto.Query.t()
  def event_logs_where_type_is_undoable("basketball", query) do
    Basketball.EventLogsOperations.where_type_is_undoable(query)
  end

  def event_logs_where_type_is_undoable(_, query) do
    query
  end

  @spec copy_all_stats_from_game_state(String.t(), GameState.t(), GameState.t()) :: GameState.t()
  def copy_all_stats_from_game_state("basketball", source_game_state, target_game_state) do
    Basketball.GameState.copy_all_stats_from_game_state(source_game_state, target_game_state)
  end

  def copy_all_stats_from_game_state(_, source_game_state, _target_game_state) do
    source_game_state
  end

  @spec map_from_snapshot(String.t(), GameState.t(), GameSnapshot.t()) :: GameState.t()
  def map_from_snapshot("basketball", game_state, snapshot) do
    Basketball.GameState.map_from_snapshot(game_state, snapshot)
  end

  def map_from_snapshot(_, game_state, snapshot) do
    case snapshot.state do
      %GameState{} = restored_state ->
        restored_state

      _ ->
        game_state
    end
  end

  @spec protest_game(String.t(), GameState.t(), map()) :: GameState.t()
  def protest_game("basketball", game_state, event_payload) do
    Basketball.GameState.protest_game(game_state, event_payload)
  end

  @spec protest_game(String.t(), GameState.t(), map()) :: GameState.t()
  def protest_game(_, game_state, _event_payload) do
    game_state
  end
end
