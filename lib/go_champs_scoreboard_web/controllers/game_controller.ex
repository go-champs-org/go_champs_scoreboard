defmodule GoChampsScoreboardWeb.GameController do
  use GoChampsScoreboardWeb, :controller

  alias GoChampsScoreboard.Games.Games

  def show(conn, %{"id" => id}) do
    case Games.get_game(id) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Game not found"})

      {:ok, game_state} ->
        json(conn, %{
          data:
            game_state
            |> Poison.encode!()
            |> Poison.decode!()
        })
    end
  end
end
