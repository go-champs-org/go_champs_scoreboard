defmodule GoChampsScoreboardWeb.ScoreboardController do
  use GoChampsScoreboardWeb, :controller
  require Logger

  def load(conn, %{"game_id" => game_id, "token" => token}) do
    conn
    |> put_session(:api_token, token)
    |> redirect(to: "/scoreboard/control/#{game_id}")
  end

  def report_data(conn, %{"game_id" => game_id, "report_slug" => report_slug}) do
    case GoChampsScoreboard.Reports.fetch_report_data(report_slug, game_id) do
      {:ok, data} ->
        json(conn, %{
          data:
            data
            |> Poison.encode!()
            |> Poison.decode!()
        })

      {:error, reason} ->
        Logger.error("Failed to fetch report data: #{inspect(reason)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to fetch report data"})
    end
  end
end
