defmodule GoChampsScoreboard.Reports do
  alias GoChampsScoreboard.Sports.Basketball

  def fetch_report_data("fiba-boxscore", game_id) do
    {:ok, Basketball.Reports.fetch_report_data("fiba-boxscore", game_id)}
  end

  def fetch_report_data("fiba-scoresheet", game_id) do
    {:ok, Basketball.Reports.fetch_report_data("fiba-scoresheet", game_id)}
  end

  def fetch_report_data("simple-example", _game_id) do
    # Simple example doesn't need real data, just return minimal structure
    {:ok, %{message: "This is a simple example report", timestamp: DateTime.utc_now()}}
  end
end
