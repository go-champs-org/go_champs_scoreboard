defmodule GoChampsScoreboard.Games.Games do
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Bootstrapper

  @spec find_or_bootstrap(String.t()) :: GameState.t()
  def find_or_bootstrap(game_id) do
    case Redix.command(:games_cache, ["GET", game_id]) do
      {:ok, nil} ->
        game_state = Bootstrapper.bootstrap()
        |> Bootstrapper.bootstrap_from_go_champs(game_id)

        Redix.command(:games_cache, ["SET", game_id, game_state])

        game_state
      {:ok, curr_game_json} ->
        GameState.from_json(curr_game_json)
    end
  end
end
