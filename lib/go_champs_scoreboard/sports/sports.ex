defmodule GoChampsScoreboard.Sports.Sports do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Sports.Basketball
  alias GoChampsScoreboard.Statistics.Models.Stat
  alias GoChampsScoreboard.Games.Models.GameClockState

  import Ecto.Query

  @spec find_player_stat(String.t(), String.t()) :: Stat.t()
  def find_player_stat("basketball", stat_id), do: Basketball.Basketball.find_player_stat(stat_id)

  @spec find_calculated_player_stats(String.t()) :: [Stat.t()]
  def find_calculated_player_stats("basketball"),
    do: Basketball.Basketball.find_calculated_player_stats()

  @spec find_team_stat(String.t(), String.t()) :: Stat.t()
  def find_team_stat("basketball", stat_id), do: Basketball.Basketball.find_team_stat(stat_id)

  @spec find_calculated_team_stats(String.t()) :: [Stat.t()]
  def find_calculated_team_stats("basketball"),
    do: Basketball.Basketball.find_calculated_team_stats()

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
end
