defmodule GoChampsScoreboard.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias GoChampsScoreboard.Repo

  alias GoChampsScoreboard.Events.EventLog

  @doc """
  Returns the list of event_logs.

  ## Examples

      iex> list_event_logs()
      [%EventLog{}, ...]

  """
  def list_event_logs do
    Repo.all(EventLog)
  end

  @doc """
  Gets a single event_log.

  Raises `Ecto.NoResultsError` if the Event log does not exist.

  ## Examples

      iex> get_event_log!(123)
      %EventLog{}

      iex> get_event_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_log!(id), do: Repo.get!(EventLog, id)

  @doc """
  Creates a event_log.

  ## Examples

      iex> create_event_log(%{field: value})
      {:ok, %EventLog{}}

      iex> create_event_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_log(attrs \\ %{}) do
    %EventLog{}
    |> EventLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event_log.

  ## Examples

      iex> update_event_log(event_log, %{field: new_value})
      {:ok, %EventLog{}}

      iex> update_event_log(event_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_log(%EventLog{} = event_log, attrs) do
    event_log
    |> EventLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_log.

  ## Examples

      iex> delete_event_log(event_log)
      {:ok, %EventLog{}}

      iex> delete_event_log(event_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_log(%EventLog{} = event_log) do
    Repo.delete(event_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_log changes.

  ## Examples

      iex> change_event_log(event_log)
      %Ecto.Changeset{data: %EventLog{}}

  """
  def change_event_log(%EventLog{} = event_log, attrs \\ %{}) do
    EventLog.changeset(event_log, attrs)
  end
end
