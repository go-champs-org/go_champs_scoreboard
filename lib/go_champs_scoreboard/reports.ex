defmodule GoChampsScoreboard.Reports do
  alias GoChampsScoreboard.Sports.Basketball

  def fetch_report_data("fiba-scoresheet", game_id) do
    {:ok, Basketball.Reports.fetch_report_data("fiba-scoresheet", game_id)}
  end
end
