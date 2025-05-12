defmodule GoChampsScoreboard.Sports.Basketball.Reports do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EventProcessor
  alias GoChampsScoreboard.Games.EventLogs

  def fetch_report_data("fiba-scoresheet", game_id) do
    game_events = EventLogs.get_all_by_game_id(game_id, with_snapshot: true)

    initial_data =
      List.last(game_events)
      |> FibaScoresheetManager.bootstrap()

    Enum.reduce(game_events, initial_data, fn event, acc ->
      EventProcessor.process(event, acc)
    end)
  end
end
