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
      score: 0,
      has_walkover: false
    }
  end

  defp bootstrap_player(player) do
    %FibaScoresheet.Player{
      id: player.id,
      name: player.name,
      number: player.number,
      signature: Map.get(player, :signature, nil),
      fouls: [],
      license_number: Map.get(player, :license_number, ""),
      is_captain: player.is_captain,
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
      signature: Map.get(coach, :signature, nil),
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
      | fouls: player.fouls ++ [foul]
    }

    all_fouls =
      if foul.type in ["F", "GD"] do
        team.all_fouls
      else
        team.all_fouls ++ [foul]
      end

    updated_team = %FibaScoresheet.Team{
      team
      | players:
          List.replace_at(
            team.players,
            Enum.find_index(team.players, fn p -> p.id == player_id end),
            updated_player
          ),
        all_fouls: all_fouls
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
      | fouls: coach.fouls ++ [foul]
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
          end
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
    updated_timeouts = team.timeouts ++ [timeout]
    %FibaScoresheet.Team{team | timeouts: updated_timeouts}
  end

  @doc """
  Mark current running score as last of period.
  """
  @spec mark_score_as_last_of_period(FibaScoresheet.Team.t()) :: FibaScoresheet.Team.t()
  def mark_score_as_last_of_period(team) do
    current_score = team.score

    case team.running_score do
      nil ->
        # No running_score map, return team as-is
        team

      running_score ->
        case running_score[current_score] do
          nil ->
            # No score to mark, return team as-is
            team

          existing_score ->
            updated_running_score =
              Map.put(running_score, current_score, %{
                existing_score
                | is_last_of_period: true
              })

            %FibaScoresheet.Team{team | running_score: updated_running_score}
        end
    end
  end

  @doc """
  Mark team fouls as last of half for both players and coaches.
  """
  @spec mark_fouls_as_last_of_half(FibaScoresheet.Team.t(), integer()) ::
          FibaScoresheet.Team.t()
  def mark_fouls_as_last_of_half(team, period) do
    updated_players =
      Enum.map(team.players, fn player ->
        update_fouls_for_period(player, period, :player)
      end)

    updated_coach = update_fouls_for_period(team.coach, period, :coach)
    updated_assistant_coach = update_fouls_for_period(team.assistant_coach, period, :coach)

    %FibaScoresheet.Team{
      team
      | players: updated_players,
        coach: updated_coach,
        assistant_coach: updated_assistant_coach
    }
  end

  defp update_fouls_for_period(person, period, person_type) do
    if is_nil(person) or is_nil(person.fouls) do
      person
    else
      case period do
        2 ->
          last_foul_index = find_last_foul_index(person.fouls, [2, 1])
          updated_fouls = mark_foul_at_index(person.fouls, last_foul_index)
          update_person_fouls(person, updated_fouls, person_type)

        4 ->
          last_foul_index = find_last_foul_index(person.fouls, [4, 3, 2, 1])
          updated_fouls = mark_foul_at_index(person.fouls, last_foul_index)
          update_person_fouls(person, updated_fouls, person_type)

        _ ->
          person
      end
    end
  end

  defp find_last_foul_index(fouls, period_priority) do
    period_priority
    |> Enum.find_value(fn period ->
      fouls
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find(fn {foul, _index} -> foul.period == period end)
      |> case do
        {_foul, index} -> index
        nil -> nil
      end
    end)
  end

  defp mark_foul_at_index(fouls, last_foul_index) when is_integer(last_foul_index) do
    fouls
    |> Enum.with_index()
    |> Enum.map(fn {foul, index} ->
      if index == last_foul_index do
        %FibaScoresheet.Foul{foul | is_last_of_half: true}
      else
        foul
      end
    end)
  end

  defp mark_foul_at_index(fouls, nil), do: fouls

  defp update_person_fouls(person, updated_fouls, :player) do
    %FibaScoresheet.Player{person | fouls: updated_fouls}
  end

  defp update_person_fouls(person, updated_fouls, :coach) do
    %FibaScoresheet.Coach{person | fouls: updated_fouls}
  end

  @doc """
  Set team with winning wo result.
  """
  @spec set_winning_wo(FibaScoresheet.Team.t()) :: FibaScoresheet.Team.t()
  def set_winning_wo(team) do
    %FibaScoresheet.Team{team | score: 20}
  end

  @doc """
  Set team with losing wo result.
  """
  @spec set_losing_wo(FibaScoresheet.Team.t()) :: FibaScoresheet.Team.t()
  def set_losing_wo(team) do
    %FibaScoresheet.Team{
      team
      | players: [],
        coach: bootstrap_coach(nil),
        assistant_coach: bootstrap_coach(nil),
        score: 0,
        has_walkover: true
    }
  end

  @doc """
  Set team players starters according to a given TeamState.
  """
  @spec set_players_starters(FibaScoresheet.Team.t(), TeamState.t()) :: FibaScoresheet.Team.t()
  def set_players_starters(team, team_state) do
    playing_player_ids =
      team_state.players
      |> Enum.filter(fn player -> player.state == :playing end)
      |> Enum.map(fn player -> player.id end)

    updated_players =
      team.players
      |> Enum.map(fn player ->
        if player.id in playing_player_ids do
          PlayerManager.set_as_starter(player)
        else
          player
        end
      end)

    %FibaScoresheet.Team{team | players: updated_players}
  end
end
