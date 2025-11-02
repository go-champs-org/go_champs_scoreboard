defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayersStateProcessor do
  @moduledoc """
  Handles the processing of update players state events in FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager

  @doc """
  Processes the update players state event and updates the FIBA scoresheet.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) do
    team_type = event_log.payload["team-type"]
    player_ids = event_log.payload["player-ids"]
    state = event_log.payload["state"]
    period = event_log.game_clock_period

    current_team = FibaScoresheetManager.find_team(data, team_type)

    updated_team =
      case state do
        "playing" ->
          update_players_to_playing(current_team, player_ids, period)

        _ ->
          current_team
      end

    FibaScoresheetManager.update_team(data, team_type, updated_team)
  end

  defp update_players_to_playing(team, player_ids, period) do
    updated_players =
      team.players
      |> Enum.map(fn player ->
        if player.id in player_ids do
          update_player_to_playing(player, period)
        else
          player
        end
      end)

    %{team | players: updated_players}
  end

  defp update_player_to_playing(player, period) do
    case player.has_played do
      value when value == nil or value == false ->
        player
        |> Map.put(:has_played, true)
        |> Map.put(:first_played_period, period)

      _ ->
        # Player has already played, just update has_played but keep original first_played_period
        player
    end
  end
end
