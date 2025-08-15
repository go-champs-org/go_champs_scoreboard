defmodule GoChampsScoreboard.Games.EventLogs do
  alias GoChampsScoreboard.Games.Messages.PubSub
  alias GoChampsScoreboard.Games.EventLogCache
  alias GoChampsScoreboard.Events.ValidatorCreator
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Events.GameSnapshot
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Sports.Sports
  import Ecto.Query

  @spec add(EventLog.t(), module(), module()) :: {:ok, EventLog.t()} | {:error, any()}
  def add(event_log, pub_sub \\ PubSub, event_log_cache \\ EventLogCache) do
    # First validate that there are existing event logs for this game
    case get_all_by_game_id(event_log.game_id) do
      [] ->
        {:error, :no_prior_event_log}

      _existing_logs ->
        Repo.transaction(fn ->
          with {:ok, inserted_event_log} <- insert_event_log(event_log),
               {:ok, prior_event_log} <- get_prior_event_log(inserted_event_log),
               {:ok, _snapshot} <- create_snapshot_from_prior(inserted_event_log, prior_event_log) do
            update_subsequent_snapshots(inserted_event_log)

            refresh_cache_and_broadcast_event_logs(
              inserted_event_log.game_id,
              pub_sub,
              event_log_cache
            )

            pub_sub.broadcast_game_last_snapshot_updated(
              inserted_event_log.game_id,
              GoChampsScoreboard.PubSub
            )

            inserted_event_log
            |> Repo.preload(:snapshot)
            |> parse_snapshot()
          else
            {:error, reason} -> Repo.rollback(reason)
          end
        end)
    end
  end

  # Insert the event log into the database
  defp insert_event_log(event_log) do
    event_log_changeset =
      %EventLog{}
      |> EventLog.changeset(%{
        key: event_log.key,
        game_id: event_log.game_id,
        payload: event_log.payload,
        timestamp: event_log.timestamp,
        game_clock_time: event_log.game_clock_time,
        game_clock_period: event_log.game_clock_period
      })

    case Repo.insert(event_log_changeset) do
      {:ok, event_log} -> {:ok, event_log}
      {:error, reason} -> {:error, reason}
    end
  end

  # Get the prior event log or return an error if none exists
  defp get_prior_event_log(event_log) do
    case get_prior(event_log) do
      nil -> {:error, :no_prior_event_log}
      prior -> {:ok, prior}
    end
  end

  # Create snapshot from the prior event log's state
  defp create_snapshot_from_prior(event_log, prior_event_log) do
    game_state_map =
      prior_event_log.snapshot.state
      |> Poison.encode!()
      |> Poison.decode!()

    snapshot_changeset =
      %GameSnapshot{}
      |> GameSnapshot.changeset(%{
        event_log_id: event_log.id,
        state: game_state_map,
        game_id: event_log.game_id
      })

    case Repo.insert(snapshot_changeset) do
      {:ok, snapshot} -> {:ok, snapshot}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec delete(Ecto.UUID.t(), module(), module()) :: {:ok, EventLog.t()} | {:error, any()}
  def delete(id, pub_sub \\ PubSub, event_log_cache \\ EventLogCache) do
    with {:ok, event_log} <- fetch_event_log(id),
         :ok <- validate_not_first_event(event_log),
         {:ok, next_event_log} <- get_next_if_exists(event_log),
         {:ok, deleted_event_log} <- do_delete(event_log) do
      case next_event_log do
        nil ->
          refresh_cache_and_broadcast_event_logs(event_log.game_id, pub_sub, event_log_cache)

          pub_sub.broadcast_game_last_snapshot_updated(
            event_log.game_id,
            GoChampsScoreboard.PubSub
          )

          {:ok, deleted_event_log}

        event ->
          update_subsequent_snapshots(event)

          refresh_cache_and_broadcast_event_logs(event_log.game_id, pub_sub, event_log_cache)

          pub_sub.broadcast_game_last_snapshot_updated(
            event_log.game_id,
            GoChampsScoreboard.PubSub
          )

          {:ok, deleted_event_log}
      end
    end
  end

  # Get the next event log if it exists
  defp get_next_if_exists(event_log) do
    # We use {:ok, nil} to indicate no next event but still success
    {:ok, get_next(event_log)}
  end

  # Perform the actual deletion
  defp do_delete(event_log) do
    case Repo.delete(event_log) do
      {:ok, deleted} -> {:ok, deleted}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec persist(Event.t(), GameState.t(), module(), module()) ::
          {:ok, EventLog.t()} | {:error, any()}
  def persist(event, game_state, event_log_cache \\ EventLogCache, pub_sub \\ PubSub) do
    Repo.transaction(fn ->
      # First, create a new event log
      event_log_changeset =
        %EventLog{}
        |> EventLog.changeset(%{
          id: Ecto.UUID.generate(),
          key: event.key,
          game_id: event.game_id,
          payload: event.payload,
          timestamp: event.timestamp,
          game_clock_time: event.clock_state_time_at,
          game_clock_period: event.clock_state_period_at
        })

      # Insert the event log
      case Repo.insert(event_log_changeset) do
        {:ok, event_log} ->
          game_state_map =
            Poison.encode!(game_state)
            |> Poison.decode!()

          snapshot_changeset =
            %GameSnapshot{}
            |> GameSnapshot.changeset(%{
              event_log_id: event_log.id,
              state: game_state_map,
              game_id: event.game_id
            })

          case Repo.insert(snapshot_changeset) do
            {:ok, _snapshot} ->
              event_log_cache.add_event_log(event.game_id, event_log)

              get_cached_events_and_broadcast(event.game_id, pub_sub, event_log_cache)

              event_log |> Repo.preload(:snapshot) |> parse_snapshot()

            {:error, reason} ->
              Repo.rollback(reason)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  @spec get(Ecto.UUID.t(), Keyword.t()) :: EventLog.t() | nil
  def get(id, opts \\ []) do
    with_snapshot? = Keyword.get(opts, :with_snapshot, false)

    if with_snapshot? do
      EventLog
      |> Repo.get(id)
      |> Repo.preload(:snapshot)
      |> parse_snapshot()
    else
      EventLog
      |> Repo.get(id)
    end
  end

  @doc """
  Retrieves all event logs associated with a given game ID.
  This function queries the database for all event logs related to the specified game ID.
  It returns a list of event logs sorted by the sport sort logic.
  ## Parameters
  - `game_id`: The ID of the game for which to retrieve event logs.
  - `opts`: Optional parameters to customize the query.
    - `:with_snapshot`: If true, preloads the snapshot associated with each event log.
    - `:game_clock_period`: Filters event logs by game clock period if provided.
    - `:key`: Filters event logs by key if provided.
    - `:order`: Determines the order of results. Accepts `:asc` (default) or `:desc`.
  ## Returns
  - A list of event logs associated with the specified game ID, sorted by the sport sort logic.
  ## Example
  ```
  iex> game_id = Ecto.UUID.generate()
  iex> event_logs = get_all_by_game_id(game_id)
  iex> event_logs
  [
    %EventLog{
      id: "some-uuid",
      key: "event_key",
      payload: %{"key" => "value"},
      timestamp: ~N[2023-10-01 12:00:00],
      game_clock_time: 120,
      game_clock_period: 1
    },
    ...
  ]
  ```
  """
  @spec get_all_by_game_id(Ecto.UUID.t(), Keyword.t()) :: [EventLog.t()]
  def get_all_by_game_id(game_id, opts \\ []) do
    with_snapshot? = Keyword.get(opts, :with_snapshot, false)
    game_clock_period = Keyword.get(opts, :game_clock_period, nil)
    key = Keyword.get(opts, :key, nil)
    order = Keyword.get(opts, :order, :asc)

    first_event_log = get_first_created_by_game_id(game_id)

    if first_event_log do
      base_query = from e in EventLog, where: e.game_id == ^game_id

      # Apply period filter if provided
      period_query =
        if game_clock_period do
          from e in base_query, where: e.game_clock_period == ^game_clock_period
        else
          base_query
        end

      # Apply key filter if provided
      key_query =
        if key do
          from e in period_query, where: e.key == ^key
        else
          period_query
        end

      # Apply ordering based on the order option
      ordered_query =
        case order do
          :desc ->
            first_event_log.snapshot.state.sport_id
            |> Sports.event_logs_reverse_order_by(key_query)

          _ ->
            first_event_log.snapshot.state.sport_id
            |> Sports.event_logs_order_by(key_query)
        end

      # Preload snapshot if requested
      query =
        if with_snapshot? do
          from e in ordered_query,
            preload: [:snapshot]
        else
          ordered_query
        end

      Enum.map(Repo.all(query), fn event_log ->
        event_log
        |> parse_snapshot()
      end)
    else
      []
    end
  end

  @doc """
  Retrieves the first event log created for a given game ID.
  This function queries the database for the first event log associated with the specified game ID.
  It returns the event log if found, or nil if no event log exists for that game ID.
  ## Parameters
  - `game_id`: The ID of the game for which to retrieve the first event log.
  ## Returns
  - The first event log created for the specified game ID, or nil if not found.
  ## Example
  ```
  iex> game_id = Ecto.UUID.generate()
  iex> event_log = get_first_created_by_game_id(game_id)
  iex> event_log
  %EventLog{
    id: "some-uuid"
    ...
  }
  ```
  """
  @spec get_first_created_by_game_id(Ecto.UUID.t()) :: EventLog.t() | nil
  def get_first_created_by_game_id(game_id) do
    query =
      from e in EventLog,
        where: e.game_id == ^game_id,
        limit: 1

    ordered_query =
      Sports.event_logs_order_by("any", query)

    case Repo.one(ordered_query)
         |> Repo.preload(:snapshot) do
      nil ->
        nil

      event_log ->
        event_log
        |> parse_snapshot()
    end
  end

  @doc """
  Retrieves the last event log for a given game ID.
  This function queries the database for the last event log associated with the specified game ID.
  It returns the event log if found, or nil if no event log exists for that game ID.
  ## Parameters
  - `game_id`: The ID of the game for which to retrieve the last event log.
  ## Returns
  - The last event log created for the specified game ID, or nil if not found.
  """
  @spec get_last_by_game_id(Ecto.UUID.t()) :: EventLog.t() | nil
  def get_last_by_game_id(game_id) do
    first_event_log = get_first_created_by_game_id(game_id)

    if first_event_log do
      base_query = from e in EventLog, where: e.game_id == ^game_id, limit: 1

      ordered_query =
        first_event_log.snapshot.state.sport_id
        |> Sports.event_logs_reverse_order_by(base_query)

      case Repo.one(ordered_query) do
        nil -> nil
        event_log -> event_log |> Repo.preload(:snapshot) |> parse_snapshot()
      end
    end
  end

  @doc """
  Retrieves the last k event logs for a given game ID.
  This function queries the database for the last k event logs associated with the specified game ID.
  It returns a list of event logs sorted by the sport sort logic.
  ## Parameters
  - `game_id`: The ID of the game for which to retrieve the last k event logs.
  - `k`: The number of event logs to retrieve.
  - `opts`: Optional parameters to customize the query.
    - `:with_snapshot`: If true, preloads the snapshot associated with each event log.

  ## Returns
  - A list of the last k event logs created for the specified game ID, or an empty list if not found.
  """
  @spec get_last_k_by_game_id(Ecto.UUID.t(), integer(), Keyword.t()) :: [EventLog.t()]
  def get_last_k_by_game_id(game_id, k, opts \\ []) do
    with_snapshot? = Keyword.get(opts, :with_snapshot, false)
    first_event_log = get_first_created_by_game_id(game_id)

    if first_event_log do
      base_query = from e in EventLog, where: e.game_id == ^game_id

      ordered_query =
        first_event_log.snapshot.state.sport_id
        |> Sports.event_logs_order_by(base_query)

      query =
        if with_snapshot? do
          from e in ordered_query,
            preload: [:snapshot]
        else
          ordered_query
        end

      # Get all events and take the last k
      query
      |> Repo.all()
      |> Enum.take(-k)
      |> Enum.map(&parse_snapshot/1)
    else
      []
    end
  end

  @doc """
  Retrieve the last undoable event log for a given game ID.
  This function queries the database for the last undoable event log associated with the specified game ID.
  It returns the event log if found, or nil if no undoable event log exists for that game ID.
  ## Parameters
  - `game_id`: The ID of the game for which to retrieve the last undoable event log.
  ## Returns
  - The last undoable event log created for the specified game ID, or nil if not found.
  """
  @spec get_last_undoable_by_game_id(Ecto.UUID.t()) :: EventLog.t() | nil
  def get_last_undoable_by_game_id(game_id) do
    first_event_log = get_first_created_by_game_id(game_id)

    if first_event_log do
      base_query = from e in EventLog, where: e.game_id == ^game_id

      filtered_query =
        first_event_log.snapshot.state.sport_id
        |> Sports.event_logs_where_type_is_undoable(base_query)

      ordered_query =
        first_event_log.snapshot.state.sport_id
        |> Sports.event_logs_order_by(filtered_query)

      event_logs = Repo.all(ordered_query)

      if event_logs != [] do
        last_event_log = List.last(event_logs)
        last_event_log |> Repo.preload(:snapshot) |> parse_snapshot()
      else
        nil
      end
    end
  end

  @doc """
  Retrieves the next event log for a given event log along with its snapshot.
  This function finds the event log that occurred immediately after the specified event log
  in the context of the same game. It returns the next event log with its snapshot if found,
  or nil if no next event log exists.

  NOTE: This function queries the database for all event logs associated with the game ID of the specified event log and finds the prior event log based on the index of the current event log in the list.
  It is important to note that this function does not persist any changes to the database.
  Instead, it simply returns the prior event log with its snapshot if found, or nil if not found.

  ## Parameters
  - `event_log`: The event log for which to retrieve the prior event log.
  ## Returns
  - The prior event log with its snapshot if found, or nil if not found.
  ## Example
  ```
  iex> event_log = %EventLog{
    id: "some-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 12:00:00],
    game_clock_time: 120,
    game_clock_period: 1
  }
  iex> next_event_log = get_next(event_log)
  iex> next_event_log
  %EventLog{
    id: "next-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 13:00:00],
    game_clock_time: 130,
    game_clock_period: 1
  }
  ```
  """
  @spec get_next(EventLog.t()) :: EventLog.t() | nil
  def get_next(event_log) do
    all_game_event_logs = get_all_by_game_id(event_log.game_id)

    number_of_event_logs = Enum.count(all_game_event_logs)

    case Enum.find_index(all_game_event_logs, fn el -> el.id == event_log.id end) do
      event_log_index when event_log_index < number_of_event_logs - 1 ->
        next_event_log_index = event_log_index + 1
        next_event_log = Enum.at(all_game_event_logs, next_event_log_index)

        if next_event_log do
          next_event_log
          |> Repo.preload(:snapshot)
          |> parse_snapshot()
        else
          nil
        end

      _ ->
        nil
    end
  end

  @doc """
  Retrieves the prior event log for a given event log along with its snapshot.
  This function finds the event log that occurred immediately before the specified event log
  in the context of the same game. It returns the prior event log with its snapshot if found,
  or nil if no prior event log exists.

  NOTE: This function queries the database for all event logs associated with the game ID of the specified event log and finds the prior event log based on the index of the current event log in the list.
  It is important to note that this function does not persist any changes to the database.
  Instead, it simply returns the prior event log with its snapshot if found, or nil if not found.

  ## Parameters
  - `event_log`: The event log for which to retrieve the prior event log.
  ## Returns
  - The prior event log with its snapshot if found, or nil if not found.
  ## Example
  ```
  iex> event_log = %EventLog{
    id: "some-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 12:00:00],
    game_clock_time: 120,
    game_clock_period: 1
  }
  iex> prior_event_log = get_prior(event_log)
  iex> prior_event_log
  %EventLog{
    id: "prior-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 11:00:00],
    game_clock_time: 100,
    game_clock_period: 1
  }
  ```
  """
  @spec get_prior(EventLog.t()) :: EventLog.t() | nil
  def get_prior(event_log) do
    all_game_event_logs = get_all_by_game_id(event_log.game_id)

    case Enum.find_index(all_game_event_logs, fn el -> el.id == event_log.id end) do
      event_log_index when event_log_index > 0 ->
        prior_event_log_index = event_log_index - 1
        prior_event_log = Enum.at(all_game_event_logs, prior_event_log_index)

        if prior_event_log do
          prior_event_log
          |> Repo.preload(:snapshot)
          |> parse_snapshot()
        else
          nil
        end

      _ ->
        nil
    end
  end

  @doc """
  Retrieves all subsequent event logs for a given list of event logs and a specific event log.
  This function finds all event logs that occurred after the specified event log in the context of the same game.
  It returns a list of subsequent event logs.

  ## Parameters
  - `all_event_logs`: A list of all event logs associated with the game ID.
  - `event_log`: The event log for which to retrieve subsequent event logs.
  ## Returns
  - A list of subsequent event logs that occurred after the specified event log.

  ## Example:
  ```
  iex> event_logs = [
    %EventLog{id: "1", game_id: "game-id", key: "event_key_1"},
    %EventLog{id: "2", game_id: "game-id", key: "event_key_2"},
    %EventLog{id: "3", game_id: "game-id", key: "event_key_3"}
  ]
  iex> event_log = %EventLog{id: "2", game_id: "game-id", key: "event_key_2"}
  iex> subsequent_event_logs = subsequent_event_logs(event_logs, event_log)
  iex> subsequent_event_logs
  [
    %EventLog{id: "3", game_id: "game-id", key: "event_key_3"}
  ]
  ```
  """
  @spec subsequent_event_logs([EventLog.t()], EventLog.t()) :: [EventLog.t()]
  def subsequent_event_logs(all_event_logs, nil) do
    all_event_logs
  end

  def subsequent_event_logs(all_event_logs, event_log) do
    event_log_index = Enum.find_index(all_event_logs, fn el -> el.id == event_log.id end)

    Enum.slice(all_event_logs, (event_log_index + 1)..Enum.count(all_event_logs))
  end

  @doc """
  Updates the payload of a single event log.
  This function updates the payload of the specified event log in the database.
  It also updates the game state snapshot for all subsequent event logs.
  ## Parameters
  - `id`: The ID of the event log to be updated.
  - `new_payload`: The new payload to be set for the event log.
  ## Returns
  - `{:ok, EventLog.t()}` if the update was successful.
  - `{:error, any()}` if there was an error during the update.
  ## Example
  ```
  iex> event_log = %EventLog{
    id: "some-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 12:00:00],
    game_clock_time: 120,
    game_clock_period: 1
  }
  iex> new_payload = %{"new_key" => "new_value"}
  iex> {:ok, updated_event_log} = update_payload(event_log.id, new_payload)
  iex> updated_event_log
  %EventLog{
    id: "some-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"new_key" => "new_value"},
    timestamp: ~N[2023-10-01 12:00:00],
    game_clock_time: 120,
    game_clock_period: 1
  }
  ```
  """
  @spec update_payload(Ecto.UUID.t(), map(), module(), module()) ::
          {:ok, EventLog.t()} | {:error, any()}
  def update_payload(id, new_payload, pub_sub \\ PubSub, event_log_cache \\ EventLogCache) do
    with {:ok, event_log} <- fetch_event_log(id),
         :ok <- validate_payload(new_payload),
         :ok <- validate_not_first_event(event_log),
         {:ok, updated_event_log} <- do_update_payload(event_log, new_payload) do
      # Call update_subsequent_snapshots but ignore its result
      # We only care that it completes successfully
      case update_subsequent_snapshots(updated_event_log) do
        {results, _final_state} when is_list(results) ->
          # Check if any update failed
          if Enum.any?(results, fn
               {:error, _} -> true
               _ -> false
             end) do
            {:error, :snapshot_update_failed}
          else
            refresh_cache_and_broadcast_event_logs(
              updated_event_log.game_id,
              pub_sub,
              event_log_cache
            )

            pub_sub.broadcast_game_last_snapshot_updated(
              updated_event_log.game_id,
              GoChampsScoreboard.PubSub
            )

            {:ok, updated_event_log}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp validate_payload(payload) do
    # Check if the payload is a map and if values are not nil
    if is_map(payload) and Enum.all?(payload, fn {_key, value} -> value != nil end) do
      :ok
    else
      {:error, :invalid_payload}
    end
  end

  # Helper to validate it's not the first event
  defp validate_not_first_event(event_log) do
    case get_prior(event_log) do
      nil ->
        {:error, :cannot_update_first_event_log}

      _prior ->
        :ok
    end
  end

  # Perform the actual payload update
  defp do_update_payload(event_log, new_payload) do
    Repo.transaction(fn ->
      case event_log
           |> EventLog.changeset(%{payload: new_payload})
           |> Repo.update() do
        {:ok, updated} -> updated
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Updates the game state snapshots for all subsequent event logs.
  This function applies each subsequent event log to the prior game state snapshot
  and updates the snapshot in the database.

  ## Parameters
  - `event_log`: The event log to be processed.
  ## Returns
  - A tuple containing:
    - A list of tuples with the result of each update operation.
    - The final game state after applying all the event logs.
  ## Example
  ```
  iex> event_log = %EventLog{
    id: "some-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 12:00:00],
    game_clock_time: 120,
    game_clock_period: 1
  }
  iex> {:ok, updated_event_logs, final_game_state} = update_subsequent_snapshots(event_log)
  iex> updated_event_logs
  [
    {:ok, %EventLog{id: "updated-uuid", ...}},
    {:ok, %EventLog{id: "updated-uuid-2", ...}}
  ]
  iex> final_game_state
  %GameState{
    players: [%{id: 1, stats: %{points: 10}}, %{id: 2, stats: %{points: 5}}]
  }
  ```
  """
  @spec update_subsequent_snapshots(EventLog.t()) :: {
          [{:ok, EventLog.t()} | {:error, any()}],
          GameState.t()
        }
  def update_subsequent_snapshots(event_log) do
    case get_prior(event_log) do
      nil ->
        {:error, :first_event_log}

      first_prior_event_log ->
        # Get all event logs for the game

        current_and_subsequent_event_logs =
          get_all_by_game_id(event_log.game_id, with_snapshot: true)
          |> subsequent_event_logs(first_prior_event_log)

        Enum.map_reduce(
          current_and_subsequent_event_logs,
          first_prior_event_log.snapshot.state,
          fn event_log, prior_game_state_snapshot ->
            updated_game_state_snapshot =
              apply_to_game_state(event_log, prior_game_state_snapshot)

            json_state =
              updated_game_state_snapshot
              |> Poison.encode!()
              |> Poison.decode!()

            snapshot_changeset =
              event_log.snapshot
              |> GoChampsScoreboard.Events.GameSnapshot.changeset(%{
                state: json_state
              })

            case Repo.update(snapshot_changeset) do
              {:ok, _snapshot} ->
                {{:ok, get(event_log.id, with_snapshot: true)}, updated_game_state_snapshot}

              {:error, reason} ->
                Repo.rollback(reason)
            end
          end
        )
    end
  end

  @doc """
  Applies an event log to a game state.
  This function processes a single event log and updates the game state accordingly.
  It is designed to be idempotent, meaning that applying the same event log multiple times
  will not change the final game state.

  ## Parameters
  - `event_log`: The event log to be processed.
  - `game_state`: The current game state to update.
  ## Returns
  - The updated game state after applying the event log.
  ## Example
  ```
  iex> event_log = %EventLog{key: "update_player_stat", payload: %{"operation" => "increment", "player_id" => 1}}
  iex> game_state = %GameState{players: [%{id: 1, stats: %{points: 0}}, %{id: 2, stats: %{points: 0}}]}
  iex> updated_game_state = apply_to_game_state(event_log, game_state)
  iex> updated_game_state.players
  [%{id: 1, stats: %{points: 1}}, %{id: 2, stats: %{points: 0}}]
  ```
  """
  @spec apply_to_game_state(EventLog.t(), GameState.t()) :: GameState.t()
  def apply_to_game_state(event_log, game_state) do
    case ValidatorCreator.create(
           event_log.key,
           event_log.game_id,
           event_log.game_clock_time,
           event_log.game_clock_period,
           event_log.payload
         ) do
      {:ok, event} ->
        if event.meta.logs_reduce_behavior == :copy_all_stats_from_game_state do
          event_log.snapshot.state.sport_id
          |> Sports.copy_all_stats_from_game_state(game_state, event_log.snapshot.state)
        else
          game_state
          |> Handler.handle(event)
        end

      {:error, reason} ->
        IO.puts("Error creating event: #{reason}")
        game_state
    end
  end

  # Fetch the event log or return an error
  defp fetch_event_log(id) do
    case get(id) do
      nil -> {:error, :not_found}
      event_log -> {:ok, event_log}
    end
  end

  defp parse_snapshot(event_log) do
    if Ecto.assoc_loaded?(event_log.snapshot) do
      # Snapshot is loaded, process it
      game_state_map =
        event_log.snapshot.state
        |> Poison.encode!()

      game_state_snapshotted = GameState.from_json(game_state_map)

      event_snapshot = %{
        event_log.snapshot
        | state: game_state_snapshotted
      }

      event_log
      |> Map.put(:snapshot, event_snapshot)
    else
      # Snapshot not loaded, return event_log as is
      event_log
    end
  end

  # Helper function to get cached events and broadcast event logs updated
  defp get_cached_events_and_broadcast(game_id, pub_sub, event_log_cache) do
    case event_log_cache.get(game_id) do
      {:ok, recent_events} ->
        pub_sub.broadcast_game_event_logs_updated(
          game_id,
          recent_events,
          GoChampsScoreboard.PubSub
        )

      {:error, _} ->
        pub_sub.broadcast_game_event_logs_updated(
          game_id,
          [],
          GoChampsScoreboard.PubSub
        )
    end
  end

  # Helper function to refresh cache and broadcast event logs updated
  defp refresh_cache_and_broadcast_event_logs(game_id, pub_sub, event_log_cache) do
    event_log_cache.refresh(game_id)
    get_cached_events_and_broadcast(game_id, pub_sub, event_log_cache)
  end
end
