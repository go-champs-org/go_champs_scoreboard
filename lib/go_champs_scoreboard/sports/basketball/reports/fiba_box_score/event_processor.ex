defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.EventProcessor do
  @moduledoc """
  EventProcessor module for FIBA boxscore.
  Routes events to the appropriate processor.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore.UpdatePlayerStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore
  alias GoChampsScoreboard.Events.EventLog

  @doc """
  Processes an event and updates the FIBA boxscore data structure.
  """
  @spec process(EventLog.t(), FibaBoxScore.t()) :: FibaBoxScore.t()
  def process(event_log, data) when event_log.key == "update-player-stat" do
    UpdatePlayerStatProcessor.process(event_log, data)
  end

  def process(_event_log, data) do
    data
  end
end
