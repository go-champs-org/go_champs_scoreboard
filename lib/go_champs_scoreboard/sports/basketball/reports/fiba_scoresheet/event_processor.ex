defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EventProcessor do
  @moduledoc """
  EventProcessor module for FIBA scoresheet.
  """

  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.EndPeriodProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateClockStateProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateCoachStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayerStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdatePlayersStateProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.UpdateTeamStatProcessor
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet
  alias GoChampsScoreboard.Events.EventLog

  @doc """
  Processes an event and updates the FIBA scoresheet data structure.
  """
  @spec process(EventLog.t(), FibaScoresheet.t()) :: FibaScoresheet.t()
  def process(event_log, data) when event_log.key == "end-game" do
    EndPeriodProcessor.process(event_log, data)
  end

  def process(event_log, data) when event_log.key == "end-period" do
    EndPeriodProcessor.process(event_log, data)
  end

  def process(event_log, data) when event_log.key == "update-clock-state" do
    IO.inspect("Updating clock state")
    UpdateClockStateProcessor.process(event_log, data)
  end

  def process(event_log, data) when event_log.key == "update-coach-stat" do
    UpdateCoachStatProcessor.process(event_log, data)
  end

  def process(event_log, data) when event_log.key == "update-player-stat" do
    UpdatePlayerStatProcessor.process(event_log, data)
  end

  def process(event_log, data) when event_log.key == "update-players-state" do
    UpdatePlayersStateProcessor.process(event_log, data)
  end

  def process(event_log, data) when event_log.key == "update-team-stat" do
    UpdateTeamStatProcessor.process(event_log, data)
  end

  def process(_event_log, data) do
    data
  end
end
