defmodule GoChampsScoreboardWeb.ScoreboardReportViewersController do
  use GoChampsScoreboardWeb, :controller
  require Logger

  def show(conn, %{"game_id" => game_id} = params) do
    case Map.get(params, "report_slug") do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing required parameter: report_slug"})

      report_slug ->
        api_token = get_session(conn, :api_token)

        report_data =
          try do
            case GoChampsScoreboard.Reports.fetch_report_data(report_slug, game_id) do
              {:ok, data} ->
                data

              _ ->
                Logger.error(
                  "Failed to fetch report data for game_id=#{game_id}, report_slug=#{report_slug}"
                )

                %{}
            end
          rescue
            FunctionClauseError ->
              Logger.debug("Unsupported report_slug=#{report_slug} for game_id=#{game_id}")

              %{}
          end

        render(conn, :show,
          api_token: api_token,
          report_slug: report_slug,
          report_data: report_data
        )
    end
  end
end
