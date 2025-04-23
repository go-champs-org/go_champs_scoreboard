defmodule GoChampsScoreboard.Games.EventLogs do
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.Models.Event
  import Ecto.Query

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

  @spec insert_after_event(Ecto.UUID.t(), Event.t()) :: {:ok, EventLog.t()} | {:error, any()}
  def insert_after_event(prior_event_id, event) do
    prior_event = Repo.get(EventLog, prior_event_id)

    if prior_event do
      after_timestamp = DateTime.add(prior_event.timestamp, 1, :microsecond)

      %EventLog{}
      |> EventLog.changeset(%{
        key: event.key,
        game_id: event.game_id,
        payload: event.payload,
        timestamp: after_timestamp,
        prior_event_id: prior_event.id
      })
      |> Repo.insert()
    else
      {:error, :prior_event_not_found}
    end
  end

  @spec update_payload(Ecto.UUID.t(), map()) :: {:ok, EventLog.t()} | {:error, any()}
  def update_payload(id, new_payload) do
    event_log = get(id)

    case event_log do
      nil ->
        {:error, :not_found}

      _ ->
        event_log
        |> EventLog.changeset(%{payload: new_payload})
        |> Repo.update()
    end
  end

  @spec get(Ecto.UUID.t()) :: EventLog.t() | nil
  def get(id) do
    EventLog
    |> Repo.get(id)
  end

  @spec delete(Ecto.UUID.t()) :: {:ok, EventLog.t()} | {:error, any()}
  def delete(id) do
    event_log = get(id)

    case event_log do
      nil -> {:error, :not_found}
      _ -> Repo.delete(event_log)
    end
  end

  @spec get_all_by_game_id(Ecto.UUID.t()) :: [EventLog.t()]
  def get_all_by_game_id(game_id) do
    query =
      from e in EventLog,
        where: e.game_id == ^game_id,
        order_by: [asc: e.timestamp]

    Repo.all(query)
  end
end
