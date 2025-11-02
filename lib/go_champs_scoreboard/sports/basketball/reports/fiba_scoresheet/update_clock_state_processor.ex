defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateClockStateProcessor do
  @moduledoc """
  Handles the processing of update clock state events in FIBA scoresheet.
  Marks players as having started when the game begins.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager

  @doc """
  Processes the update clock state event and updates the FIBA scoresheet.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    game_clock_time = event_log.game_clock_time
    game_clock_period = event_log.game_clock_period
    initial_period_time = data.info.initial_period_time
    state = event_log.payload["state"]

    if game_clock_time == initial_period_time and game_clock_period == 1 and state == "running" do
      home_playing_players = get_playing_player_ids(event_log.snapshot.state.home_team)
      away_playing_players = get_playing_player_ids(event_log.snapshot.state.away_team)

      data
      |> update_team_starting_players("home", home_playing_players)
      |> update_team_starting_players("away", away_playing_players)
    else
      data
    end
  end

  defp get_playing_player_ids(team_state) do
    team_state.players
    |> Enum.filter(fn player -> player.state == :playing end)
    |> Enum.map(fn player -> player.id end)
  end

  defp update_team_starting_players(data, team_type, playing_player_ids) do
    current_team = FibaScoresheetManager.find_team(data, team_type)

    updated_players =
      current_team.players
      |> Enum.map(fn player ->
        if player.id in playing_player_ids do
          update_playing_player(player)
        else
          player
        end
      end)

    updated_team = %{current_team | players: updated_players}

    FibaScoresheetManager.update_team(data, team_type, updated_team)
  end

  defp update_playing_player(player) do
    player
    |> Map.put(:has_played, true)
    |> Map.put(:has_started, true)
    |> Map.put(:first_played_period, 1)
  end
end
