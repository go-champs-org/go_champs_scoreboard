defmodule GoChampsScoreboard.Games.EventLogs do
  alias GoChampsScoreboard.Events.ValidatorCreator
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Sports.Sports
  import Ecto.Query

  @spec delete(Ecto.UUID.t()) :: {:ok, EventLog.t()} | {:error, any()}
  @spec delete(Ecto.UUID.t()) :: {:ok, EventLog.t()} | {:error, any()}
  def delete(id) do
    with {:ok, event_log} <- fetch_event_log(id),
         :ok <- validate_not_first_event(event_log),
         {:ok, next_event_log} <- get_next_event_log_if_exists(event_log),
         {:ok, deleted_event_log} <- do_delete(event_log) do
      case next_event_log do
        nil ->
          {:ok, deleted_event_log}

        event ->
          # Update snapshots if next event exists
          update_subsequent_event_log_snapshots(event)
          {:ok, deleted_event_log}
      end
    end
  end

  # Fetch the event log or return an error
  defp fetch_event_log(id) do
    case get(id) do
      nil -> {:error, :not_found}
      event_log -> {:ok, event_log}
    end
  end

  # Validate that we're not trying to delete the first event
  defp validate_not_first_event(event_log) do
    first_event_log = get_first_created_by_game_id(event_log.game_id)

    if event_log.id == first_event_log.id do
      {:error, :cannot_delete_first_event_log}
    else
      :ok
    end
  end

  # Get the next event log if it exists
  defp get_next_event_log_if_exists(event_log) do
    # We use {:ok, nil} to indicate no next event but still success
    {:ok, get_next_event_log(event_log)}
  end

  # Perform the actual deletion
  defp do_delete(event_log) do
    case Repo.delete(event_log) do
      {:ok, deleted} -> {:ok, deleted}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec persist(Event.t(), GameState.t()) :: :ok | {:error, any()}
  def persist(event, game_state) do
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
            %GoChampsScoreboard.Events.GameSnapshot{}
            |> GoChampsScoreboard.Events.GameSnapshot.changeset(%{
              event_log_id: event_log.id,
              state: game_state_map,
              game_id: event.game_id
            })

          case Repo.insert(snapshot_changeset) do
            {:ok, _snapshot} ->
              event_log |> Repo.preload(:snapshot) |> parse_snapshot()

            {:error, reason} ->
              Repo.rollback(reason)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  # @spec update_payload(Ecto.UUID.t(), map()) :: {:ok, EventLog.t()} | {:error, any()}
  # def update_payload(id, new_payload) do
  #   event_log = get(id)

  #   case event_log do
  #     nil ->
  #       {:error, :not_found}

  #     _ ->
  #       event_log
  #       |> EventLog.changeset(%{payload: new_payload})
  #       |> Repo.update()
  #   end
  # end

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

      ordered_query =
        first_event_log.snapshot.state.sport_id
        |> Sports.event_logs_order_by(key_query)

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
  iex> next_event_log = get_next_event_log(event_log)
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
  @spec get_next_event_log(EventLog.t()) :: EventLog.t() | nil
  def get_next_event_log(event_log) do
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
  iex> prior_event_log = get_pior_event_log(event_log)
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
  @spec get_pior_event_log(EventLog.t()) :: EventLog.t() | nil
  def get_pior_event_log(event_log) do
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
  def subsequent_event_logs(all_event_logs, event_log) do
    event_log_index = Enum.find_index(all_event_logs, fn el -> el.id == event_log.id end)

    Enum.slice(all_event_logs, (event_log_index + 1)..Enum.count(all_event_logs))
  end

  @doc """
  Updates the game state snapshot for a single event log.
  This function applies the event log to the prior game state snapshot and updates the snapshot in the database.
  It is designed to be idempotent, meaning that applying the same event log multiple times
  will not change the final game state snapshot.
  ## Parameters
  - `event_log`: The event log to be processed.
  - `prior_event_log`: The prior event log to use as the base for the update.
  ## Returns
  - `{:ok, GameSnapshot.t()}` if the update was successful.
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
  iex> prior_event_log = %EventLog{
    id: "prior-uuid",
    game_id: "game-id",
    key: "event_key",
    payload: %{"key" => "value"},
    timestamp: ~N[2023-10-01 11:00:00],
    game_clock_time: 100,
    game_clock_period: 1
  }
  iex> {:ok, updated_event_log} = update_single_event_snapshot(event_log, prior_event_log)
  ```
  """
  @spec update_single_event_snapshot(EventLog.t(), EventLog.t()) ::
          {:ok, EventLog.t()} | {:error, any()}
  def update_single_event_snapshot(event_log, prior_event_log) do
    updated_game_state_snapshot =
      apply_event_log_to_game_state(event_log, prior_event_log.snapshot.state)

    json_state =
      updated_game_state_snapshot
      |> Poison.encode!()
      |> Poison.decode!()

    snapshot_changeset =
      event_log.snapshot
      |> GoChampsScoreboard.Events.GameSnapshot.changeset(%{
        state: json_state
      })

    Repo.update(snapshot_changeset)
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
  iex> {:ok, updated_event_logs, final_game_state} = update_subsequent_event_log_snapshots(event_log)
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
  @spec update_subsequent_event_log_snapshots(EventLog.t()) :: {
          [{:ok, EventLog.t()} | {:error, any()}],
          GameState.t()
        }
  def update_subsequent_event_log_snapshots(event_log) do
    first_prior_event_log = get_pior_event_log(event_log)

    current_and_subsequent_event_logs =
      get_all_by_game_id(event_log.game_id, with_snapshot: true)
      |> subsequent_event_logs(first_prior_event_log)

    Enum.map_reduce(
      current_and_subsequent_event_logs,
      first_prior_event_log.snapshot.state,
      fn event_log, prior_game_state_snapshot ->
        updated_game_state_snapshot =
          apply_event_log_to_game_state(event_log, prior_game_state_snapshot)

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

  @doc """
  Reduces a list of event logs to a game state starting with a giving game state.
  This function processes a list of event logs and returns the final game state.
  It applies the events in the order they occurred, updating the game state accordingly.
  The function is designed to be idempotent, meaning that applying the same event log multiple times
  will not change the final game state.
  The function is also designed to be pure, meaning that it does not have any side effects
  and does not modify any external state.
  It is important to note that this function does not persist any changes to the database.
  Instead, it simply returns the final game state after applying all the event logs.


  ## Parameters
  - `event_logs`: A list of event logs to be processed.
  - `game_state`: The initial game state to start with.

  ## Returns
  - A list of event logs that were processed.
  - The final game state after applying all the event logs.
  ## Example
  ```
  iex> event_logs = [
  ...>   %EventLog{key: "update_player_stat", payload: %{"operation" => "increment", "player_id" => 1}},
  ...>   %EventLog{key: "update_player_stat", payload: %{"operation" => "decrement", "player_id" => 2}}
  ...> ]
  iex> initial_game_state = %GameState{players: [%{id: 1, stats: %{points: 0}}, %{id: 2, stats: %{points: 0}}]}
  iex> final_game_state = reduce_event_logs_to_game_state(event_logs, initial_game_state)
  iex> final_game_state.players
  [%{id: 1, stats: %{points: 1}}, %{id: 2, stats: %{points: -1}}]
  ```
  """
  @spec reduce_event_logs_to_game_state([EventLog.t()], GameState.t()) :: [EventLog.t()]
  def reduce_event_logs_to_game_state(event_logs, game_state) do
    Enum.reduce(event_logs, game_state, fn event_log, acc ->
      apply_event_log_to_game_state(event_log, acc)
    end)
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
  iex> updated_game_state = apply_event_log_to_game_state(event_log, game_state)
  iex> updated_game_state.players
  [%{id: 1, stats: %{points: 1}}, %{id: 2, stats: %{points: 0}}]
  ```
  """
  @spec apply_event_log_to_game_state(EventLog.t(), GameState.t()) :: GameState.t()
  def apply_event_log_to_game_state(event_log, game_state) do
    case ValidatorCreator.create(
           event_log.key,
           event_log.game_id,
           event_log.game_clock_time,
           event_log.game_clock_period,
           event_log.payload
         ) do
      {:ok, event} ->
        game_state
        |> Handler.handle(event)

      {:error, reason} ->
        IO.puts("Error creating event: #{reason}")
        game_state
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
end
