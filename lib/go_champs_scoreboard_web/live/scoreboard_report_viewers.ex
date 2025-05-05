defmodule GoChampsScoreboardWeb.ScoreboardReportViewers do
  use GoChampsScoreboardWeb, :live_view
  require Logger

  def mount(%{"game_id" => _game_id}, %{"api_token" => api_token} = _session, socket) do
    {:ok,
     socket
     |> assign(:api_token, api_token)
     |> assign(:report_data, %{})}
  end
end
