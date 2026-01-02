defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.ProtestManager do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Teams

  @spec bootstrap(GameState.t()) :: FibaScoresheet.Protest.t()
  def bootstrap(game_state) do
    case game_state.protest do
      nil ->
        %FibaScoresheet.Protest{
          player_name: "",
          state: :no_protest
        }

      protest_state ->
        player_name = get_player_name(game_state, protest_state)
        protest_signature = get_player_signature(game_state, protest_state)

        %FibaScoresheet.Protest{
          player_name: player_name,
          state: protest_state.state,
          signature: protest_signature
        }
    end
  end

  @spec get_player_name(GameState.t(), any()) :: String.t()
  defp get_player_name(game_state, protest_state) do
    team_type =
      case protest_state.team_type do
        :home -> "home"
        :away -> "away"
        _ -> nil
      end

    case team_type do
      nil ->
        ""

      team_type_string ->
        case Teams.find_player(game_state, team_type_string, protest_state.player_id) do
          nil -> ""
          player -> player.name
        end
    end
  end

  @spec get_player_signature(GameState.t(), any()) :: String.t() | nil
  defp get_player_signature(game_state, protest_state) do
    team_type =
      case protest_state.team_type do
        :home -> "home"
        :away -> "away"
        _ -> nil
      end

    case team_type do
      nil ->
        nil

      team_type_string ->
        case Teams.find_player(game_state, team_type_string, protest_state.player_id) do
          nil -> nil
          player -> player.signature
        end
    end
  end
end
