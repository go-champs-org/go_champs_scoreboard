defmodule GoChampsScoreboardWeb.ScoreboardReportViewers do
  use GoChampsScoreboardWeb, :live_view
  require Logger

  def mount(%{"game_id" => game_id}, %{"api_token" => api_token} = _session, socket) do
    report_data =
      case GoChampsScoreboard.Reports.fetch_report_data("fiba-scoresheet", game_id) do
        {:ok, data} -> data
      end

    {:ok,
     socket
     |> assign(:api_token, api_token)
     |> assign(:report_data, report_data)}
  end
end
