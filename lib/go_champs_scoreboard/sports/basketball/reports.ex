defmodule GoChampsScoreboard.Sports.Basketball.Reports do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EventProcessor
  alias GoChampsScoreboard.Games.EventLogs
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet

  def fetch_report_data("fiba-scoresheet", game_id) do
    game_events = EventLogs.get_all_by_game_id(game_id)

    initial_data = %FibaScoresheet{
      game_id: game_id
    }

    Enum.reduce(game_events, initial_data, fn event, acc ->
      EventProcessor.process(event, acc)
    end)
  end
end
