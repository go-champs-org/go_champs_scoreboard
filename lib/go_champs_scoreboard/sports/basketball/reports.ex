defmodule GoChampsScoreboard.Sports.Basketball.Reports do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.FibaBoxScoreManager

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.EventProcessor,
    as: FibaBoxScoreEventProcessor

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.FibaScoresheetManager
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EventProcessor
  alias GoChampsScoreboard.Games.EventLogs

  def fetch_report_data("fiba-boxscore", game_id) do
    game_events = EventLogs.get_all_by_game_id(game_id, with_snapshot: true)

    case List.last(game_events) do
      nil ->
        nil

      last_event ->
        initial_data = FibaBoxScoreManager.bootstrap(last_event)

        Enum.reduce(game_events, initial_data, fn event, acc ->
          FibaBoxScoreEventProcessor.process(event, acc)
        end)
        |> FibaBoxScoreManager.finalize()
    end
  end

  def fetch_report_data("fiba-scoresheet", game_id) do
    game_events = EventLogs.get_all_by_game_id(game_id, with_snapshot: true)

    case List.last(game_events) do
      nil ->
        nil

      last_event ->
        initial_data = FibaScoresheetManager.bootstrap(last_event)

        Enum.reduce(game_events, initial_data, fn event, acc ->
          EventProcessor.process(event, acc)
        end)
    end
  end
end
