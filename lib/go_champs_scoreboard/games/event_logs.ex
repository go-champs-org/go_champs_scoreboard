defmodule GoChampsScoreboard.Games.EventLogs do
  alias GoChampsScoreboard.Events.ValidatorCreator
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Repo
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Handler
  import Ecto.Query

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
            {:ok, _snapshot} -> event_log |> Repo.preload(:snapshot)
            {:error, reason} -> Repo.rollback(reason)
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

  @spec get(Ecto.UUID.t()) :: EventLog.t() | nil
  def get(id) do
    EventLog
    |> Repo.get(id)
  end

  # @spec delete(Ecto.UUID.t()) :: {:ok, EventLog.t()} | {:error, any()}
  # def delete(id) do
  #   event_log = get(id)

  #   case event_log do
  #     nil -> {:error, :not_found}
  #     _ -> Repo.delete(event_log)
  #   end
  # end

  @spec get_all_by_game_id(Ecto.UUID.t()) :: [EventLog.t()]
  def get_all_by_game_id(game_id) do
    query =
      from e in EventLog,
        where: e.game_id == ^game_id,
        order_by: [asc: e.game_clock_period, desc: e.game_clock_time, asc: e.timestamp]

    Repo.all(query)
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
end
