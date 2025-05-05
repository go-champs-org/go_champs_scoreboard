defmodule GoChampsScoreboard.Sports.Basketball.Reports do
  def fetch_report_data("fiba-scoresheet", game_id) do
    %{
      game_id: game_id
    }
  end
end
