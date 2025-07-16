defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.TeamManager do
  @moduledoc """
  Handles the construction of team data structures for FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.PlayerManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.CoachManager
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  @doc """
  Bootstraps a team with initial values.
  """
  @spec bootstrap(TeamState.t()) :: FibaScoresheet.Team.t()
  def bootstrap(team_state) do
    %FibaScoresheet.Team{
      name: team_state.name,
      players:
        team_state.players
        |> Enum.filter(fn player -> player.state != :not_available end)
        |> Enum.map(&bootstrap_player/1),
      coach:
        (Map.get(team_state, :coaches) ||
           [])
        |> Enum.find(fn coach -> coach.type == :head_coach end)
        |> bootstrap_coach(),
      assistant_coach:
        (Map.get(team_state, :coaches) ||
           [])
        |> Enum.find(fn coach -> coach.type == :assistant_coach end)
        |> bootstrap_coach(),
      all_fouls: [],
      timeouts: [],
      running_score: %{},
      score: 0
    }
  end

  defp bootstrap_player(player) do
    %FibaScoresheet.Player{
      id: player.id,
      name: player.name,
      number: player.number,
      fouls: [],
      is_captain: nil,
      has_played: nil,
      has_started: nil
    }
  end

  defp bootstrap_coach(nil) do
    %FibaScoresheet.Coach{
      id: "",
      name: "",
      fouls: []
    }
  end

  defp bootstrap_coach(coach) do
    %FibaScoresheet.Coach{
      id: Map.get(coach, :id, ""),
      name: Map.get(coach, :name, ""),
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

  @spec add_coach_foul(FibaScoresheet.Team.t(), String.t(), FibaScoresheet.Foul.t()) ::
          FibaScoresheet.Team.t()
  def add_coach_foul(team, coach_id, foul) do
    coach =
      team
      |> CoachManager.find_coach(coach_id)

    updated_coach = %FibaScoresheet.Coach{
      coach
      | fouls: [foul | coach.fouls]
    }

    updated_team = %FibaScoresheet.Team{
      team
      | coach:
          if coach.id == team.coach.id do
            updated_coach
          else
            team.coach
          end,
        assistant_coach:
          if coach.id == team.assistant_coach.id do
            updated_coach
          else
            team.assistant_coach
          end,
        all_fouls: [foul | team.all_fouls]
    }

    updated_team
  end

  @doc """
  Updates a player in the team.
  """
  @spec update_player(FibaScoresheet.Player.t(), FibaScoresheet.Team.t()) ::
          FibaScoresheet.Team.t()
  def update_player(player, team) do
    updated_players =
      Enum.map(team.players, fn p ->
        if p.id == player.id do
          player
        else
          p
        end
      end)

    %FibaScoresheet.Team{team | players: updated_players}
  end

  @doc """
  Adds a timeout to the team's timeouts list.
  """
  @spec add_timeout(FibaScoresheet.Team.t(), FibaScoresheet.Timeout.t()) ::
          FibaScoresheet.Team.t()
  def add_timeout(team, timeout) do
    updated_timeouts = [timeout | team.timeouts]
    %FibaScoresheet.Team{team | timeouts: updated_timeouts}
  end

  @doc """
  Mark current running score as last of period.
  """
  @spec mark_score_as_last_of_period(FibaScoresheet.Team.t()) :: FibaScoresheet.Team.t()
  def mark_score_as_last_of_period(team) do
    current_score = team.score

    updated_running_score =
      Map.put(team.running_score, current_score, %{
        team.running_score[current_score]
        | is_last_of_period: true
      })

    %FibaScoresheet.Team{team | running_score: updated_running_score}
  end
end
