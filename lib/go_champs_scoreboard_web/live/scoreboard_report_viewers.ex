defmodule GoChampsScoreboardWeb.ScoreboardReportViewers do
  use GoChampsScoreboardWeb, :live_view
  require Logger

  def mount(
        %{"game_id" => game_id, "report_slug" => report_slug},
        %{"api_token" => api_token} = _session,
        socket
      ) do
    report_data =
      case GoChampsScoreboard.Reports.fetch_report_data(report_slug, game_id) do
        {:ok, data} ->
          data

        {:error, reason} ->
          Logger.error("Failed to fetch report data: #{inspect(reason)}")
          # fallback empty data
          %{}
      end

    {:ok,
     socket
     |> assign(:api_token, api_token)
     |> assign(:report_slug, report_slug)
     |> assign(:report_data, report_data)}
  end
end
