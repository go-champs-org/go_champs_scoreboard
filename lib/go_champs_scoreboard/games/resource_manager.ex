defmodule GoChampsScoreboard.Games.ResourceManager do
  @moduledoc """
  This module is responsible for managing the resources of a game.
  """
  @behaviour GoChampsScoreboard.Games.ResourceManagerBehavior

  alias GoChampsScoreboard.Infrastructure.GameEventsListenerSupervisor
  alias GoChampsScoreboard.Infrastructure.GameEventLogsListenerSupervisor
  alias GoChampsScoreboard.Infrastructure.GameTickerSupervisor

  @impl true
  @spec check_and_restart(String.t(), module(), module(), module()) :: :ok | {:error, any()}
  def check_and_restart(
        game_id,
        game_events_listener_supervisor \\ GameEventsListenerSupervisor,
        game_event_logs_listener_supervisor \\ GameEventLogsListenerSupervisor,
        game_ticker_supervisor \\ GameTickerSupervisor
      ) do
    with :ok <-
           check_and_start_if_needed(
             game_events_listener_supervisor,
             :check_game_events_listener,
             :start_game_events_listener,
             game_id
           ),
         :ok <-
           check_and_start_if_needed(
             game_event_logs_listener_supervisor,
             :check_game_event_logs_listener,
             :start_game_event_logs_listener,
             game_id
           ),
         :ok <-
           check_and_start_if_needed(
             game_ticker_supervisor,
             :check_game_ticker,
             :start_game_ticker,
             game_id
           ) do
      :ok
    end
  end

  # Helper function to check and start supervisor processes if needed
  defp check_and_start_if_needed(supervisor, check_func, start_func, game_id) do
    case apply(supervisor, check_func, [game_id]) do
      {:error, :not_found} ->
        case apply(supervisor, start_func, [game_id]) do
          {:ok, _pid} -> :ok
          error -> error
        end

      _ ->
        :ok
    end
  end

  @impl true
  @spec start_up(String.t(), module(), module(), module()) :: :ok | {:error, any()}
  def start_up(
        game_id,
        game_events_listener_supervisor \\ GameEventsListenerSupervisor,
        game_event_logs_listener_supervisor \\ GameEventLogsListenerSupervisor,
        game_ticker_supervisor \\ GameTickerSupervisor
      ) do
    with {:ok, _} <-
           normalize_result(game_events_listener_supervisor.start_game_events_listener(game_id)),
         {:ok, _} <-
           normalize_result(
             game_event_logs_listener_supervisor.start_game_event_logs_listener(game_id)
           ),
         {:ok, _} <- normalize_result(game_ticker_supervisor.start_game_ticker(game_id)) do
      :ok
    end
  end

  @impl true
  @spec shut_down(String.t(), module(), module(), module()) :: :ok | {:error, any()}
  def shut_down(
        game_id,
        game_events_listener_supervisor \\ GameEventsListenerSupervisor,
        game_event_logs_listener_supervisor \\ GameEventLogsListenerSupervisor,
        game_ticker_supervisor \\ GameTickerSupervisor
      ) do
    with {:ok, _} <-
           normalize_result(game_events_listener_supervisor.stop_game_events_listener(game_id)),
         {:ok, _} <-
           normalize_result(
             game_event_logs_listener_supervisor.stop_game_event_logs_listener(game_id)
           ),
         {:ok, _} <- normalize_result(game_ticker_supervisor.stop_game_ticker(game_id)) do
      :ok
    end
  end

  # Helper function to normalize supervisor return values
  defp normalize_result({:ok, _pid}), do: {:ok, :normalized}
  defp normalize_result({:error, _reason} = error), do: error
  defp normalize_result(:ok), do: {:ok, :normalized}
end

defmodule GoChampsScoreboard.Games.ResourceManagerBehavior do
  @callback check_and_restart(String.t()) :: :ok | {:error, any()}
  @callback start_up(String.t()) :: :ok | {:error, any()}
  @callback shut_down(String.t()) :: :ok | {:error, any()}
end
