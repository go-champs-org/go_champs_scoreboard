defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager do
  @moduledoc """
  Handles the construction of team data structures for FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  @doc """
  Bootstraps a team with initial values.
  """
  @spec bootstrap(TeamState.t()) :: FibaScoresheet.Team.t()
  def bootstrap(team_state) do
    %FibaScoresheet.Team{
      name: team_state.name,
      players: Enum.map(team_state.players, &bootstrap_player/1),
      coach: %FibaScoresheet.Coach{
        id: "coach-id",
        name: "First coach",
        fouls: []
      },
      assistant_coach: %FibaScoresheet.Coach{
        id: "ass-coach",
        name: "Ass Coach",
        fouls: []
      },
      all_fouls: [],
      running_score: %{},
      score: 0
    }
  end

  defp bootstrap_player(player) do
    %FibaScoresheet.Player{
      id: player.id,
      name: player.name,
      number: player.number,
      fouls: []
    }
  end

  @doc """
  Updates the running score for a team.
  """
  @spec add_score(FibaScoresheet.Team.t(), FibaScoresheet.PointScore.t()) ::
          FibaScoresheet.Team.t()
  def add_score(team, point_score) do
    score =
      case point_score.type do
        "2PT" -> team.score + 2
        "3PT" -> team.score + 3
        "FT" -> team.score + 1
        _ -> team.score
      end

    running_score = Map.put(team.running_score, score, point_score)

    %{team | running_score: running_score, score: score}
  end

  @doc """
  Update player fouls and team fouls for a team.
  """
  @spec add_player_foul(FibaScoresheet.Team.t(), String.t(), FibaScoresheet.Foul.t()) ::
          FibaScoresheet.Team.t()
  def add_player_foul(team, player_id, foul) do
    player =
      team
      |> PlayerManager.find_player(player_id)

    updated_player = %FibaScoresheet.Player{
      player
      | fouls: [foul | player.fouls]
    }

    updated_team = %FibaScoresheet.Team{
      team
      | players:
          List.replace_at(
            team.players,
            Enum.find_index(team.players, fn p -> p.id == player_id end),
            updated_player
          ),
        all_fouls: [foul | team.all_fouls]
    }

    updated_team
  end
end
