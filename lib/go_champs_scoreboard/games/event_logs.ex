defmodule GoChampsScoreboard.Games.EventLogs do
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.Models.Event

  @spec persist(Event.t()) :: :ok | {:error, any()}
  def persist(event) do
    %EventLog{}
    |> EventLog.changeset(%{
      key: event.key,
      game_id: event.game_id,
      payload: event.payload,
      timestamp: event.timestamp
    })
    |> Repo.insert()
  end
end
