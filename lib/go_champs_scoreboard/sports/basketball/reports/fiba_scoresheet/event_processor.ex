defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EventProcessor do
  @moduledoc """
  EventProcessor module for FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  @doc """
  Processes an event and updates the FIBA scoresheet data structure.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) when event_log.key == 'update-player-stat' do
    UpdatePlayerStatProcessor.process(event_log, data)
  end

  def process(_event_log, data) do
    data
  end
end
