defmodule GoChampsScoreboardWeb.GameControllerTest do
  alias GoChampsScoreboard.GameStateFixtures
  use GoChampsScoreboardWeb.ConnCase

  describe "show" do
    test "renders game state", %{conn: conn} do
      game_state = set_test_game()

      conn = get(conn, ~p"/v1/games/#{game_state.id}")

      assert json_response(conn, 200)["data"]["id"] == game_state.id

      unset_test_game(game_state.id)
    end

    test "returns 404 if game not found", %{conn: conn} do
      random_id = Ecto.UUID.generate()
      conn = get(conn, ~p"/v1/games/#{random_id}")
      assert json_response(conn, 404)["error"] == "Game not found"
    end
  end

  defp set_test_game() do
    game_state = GameStateFixtures.game_state_fixture()
    Redix.command(:games_cache, ["SET", game_state.id, game_state])
    game_state
  end

  defp unset_test_game(game_id) do
    Redix.command(:games_cache, ["DEL", game_id])
  end
end
