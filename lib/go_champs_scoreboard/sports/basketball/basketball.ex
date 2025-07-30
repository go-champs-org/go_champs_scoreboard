defmodule GoChampsScoreboard.Sports.Basketball.Basketball do
  alias GoChampsScoreboard.Sports.Basketball.Statistics
  alias GoChampsScoreboard.Statistics.Models.Stat

  @player_stats [
    Stat.new("assists", :manual, [:increment, :decrement]),
    Stat.new("blocks", :manual, [:incremen, :decrement]),
    Stat.new("disqualifications", :manual, [:increment, :decrement]),
    Stat.new("ejections", :manual, [:increment, :decrement]),
    Stat.new("efficiency", :manual, [:incremen, :decrement]),
    Stat.new(
      "field_goal_percentage",
      :calculated,
      [],
      &Statistics.calc_player_field_goal_percentage/1
    ),
    Stat.new(
      "field_goals_attempted",
      :calculated,
      [],
      &Statistics.calc_player_field_goals_attempted/1
    ),
    Stat.new("field_goals_missed", :manual, [:increment, :decrement]),
    Stat.new("field_goals_made", :manual, [:incremen, :decrement]),
    Stat.new("fouls", :calculated, [], &Statistics.calc_player_fouls/1),
    Stat.new("fouls_flagrant", :manual, [:incremen, :decrement]),
    Stat.new("fouls_personal", :manual, [:incremen, :decrement]),
    Stat.new("fouls_technical", :manual, [:increment, :decrement]),
    Stat.new(
      "free_throw_percentage",
      :calculated,
      [],
      &Statistics.calc_player_free_throw_percentage/1
    ),
    Stat.new(
      "free_throws_attempted",
      :calculated,
      [],
      &Statistics.calc_player_free_throws_attempted/1
    ),
    Stat.new("free_throws_missed", :manual, [:increment, :decrement]),
    Stat.new("free_throws_made", :manual, [:incremen, :decrement]),
    Stat.new("game_played", :manual, [:increment, :decrement]),
    Stat.new("game_started", :manual, [:incremen, :decrement]),
    Stat.new("minutes_played", :automatic, [:incremen, :decrement]),
    Stat.new("plus_minus", :manual, [:incremen, :decrement]),
    Stat.new("points", :calculated, [], &Statistics.calc_player_points/1),
    Stat.new("rebounds", :calculated, [], &Statistics.calc_player_rebounds/1),
    Stat.new("rebounds_defensive", :manual, [:incremen, :decrement]),
    Stat.new("rebounds_offensive", :manual, [:incremen, :decrement]),
    Stat.new("steals", :manual, [:incremen, :decrement]),
    Stat.new(
      "three_point_field_goal_percentage",
      :calculated,
      [],
      &Statistics.calc_player_three_point_field_goal_percentage/1
    ),
    Stat.new(
      "three_point_field_goals_attempted",
      :calculated,
      [],
      &Statistics.calc_player_three_point_field_goals_attempted/1
    ),
    Stat.new("three_point_field_goals_missed", :manual, [:increment, :decrement]),
    Stat.new("three_point_field_goals_made", :manual, [:incremen, :decrement]),
    Stat.new("turnovers", :manual, [:increment, :decrement])
  ]

  @team_stats [
    Stat.new("timeouts", :manual, [:increment, :decrement]),
    Stat.new("fouls_technical", :manual, [:increment, :decrement]),
    Stat.new("total_fouls_technical", :calculated, [], &Statistics.calc_team_technical_fouls/1)
  ]

  @spec bootstrap() :: %{String.t() => number()}
  def bootstrap() do
    Enum.reduce(@player_stats, %{}, fn stat, player_stats ->
      Map.merge(player_stats, %{stat.key => 0})
    end)
  end

  @spec bootstrap_team_stats() :: %{String.t() => number()}
  def bootstrap_team_stats() do
    Enum.reduce(@team_stats, %{}, fn stat, team_stats ->
      Map.merge(team_stats, %{stat.key => 0})
    end)
  end

  @spec find_player_stat(String.t()) :: Stat.t()
  def find_player_stat(stat_id) do
    Enum.find(@player_stats, fn stat -> stat.key == stat_id end)
  end

  @spec find_calculated_player_stats() :: [Stat.t()]
  def find_calculated_player_stats() do
    Enum.filter(@player_stats, fn stat -> stat.type == :calculated end)
  end

  @spec find_team_stat(String.t()) :: Stat.t()
  def find_team_stat(stat_id) do
    Enum.find(@team_stats, fn stat -> stat.key == stat_id end)
  end

  @spec find_calculated_team_stats() :: [Stat.t()]
  def find_calculated_team_stats() do
    Enum.filter(@team_stats, fn stat -> stat.type == :calculated end)
  end
end
