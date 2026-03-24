defmodule GoChampsScoreboard.Games.ResourceManagerTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.ResourceManager
  import Mox

  alias GoChampsScoreboard.Games.GameProcessSupervisorMock
  alias GoChampsScoreboard.Infrastructure.GameEventsListenerSupervisorMock
  alias GoChampsScoreboard.Infrastructure.GameEventLogsListenerSupervisorMock
  alias GoChampsScoreboard.Infrastructure.GameTickerSupervisorMock

  describe "check_and_restart/1" do
    test "starts GameTicker for game-id if not running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id -> :ok end)

      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> {:error, :not_found} end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      expect(GameTickerSupervisorMock, :start_game_ticker, fn _game_id -> :ok end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end

    test "does not start GameTicker for game-id if already running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id -> :ok end)
      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> :ok end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end

    test "starts EventListener for game-id if not running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id -> :ok end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id ->
        {:error, :not_found}
      end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> :ok end)

      expect(GameEventsListenerSupervisorMock, :start_game_events_listener, fn _game_id -> :ok end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end

    test "does not start EventListener for game-id if already running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id -> :ok end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> :ok end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end

    test "starts GameProcess for game-id if not running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id ->
        {:error, :not_found}
      end)

      expect(GameProcessSupervisorMock, :start_game_process, fn _game_id -> {:ok, self()} end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> :ok end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end

    test "starts EventLogsListener for game-id if not running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id -> :ok end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        {:error, :not_found}
      end)

      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :start_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end

    test "does not start EventLogsListener for game-id if already running" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :check_game_process, fn _game_id -> :ok end)

      expect(GameEventsListenerSupervisorMock, :check_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :check_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      expect(GameTickerSupervisorMock, :check_game_ticker, fn _game_id -> :ok end)

      :ok =
        ResourceManager.check_and_restart(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end
  end

  describe "start_up/1" do
    test "starts GameProcess first, then listeners, then GameTicker" do
      game_id = "some-game-id"

      expect(GameProcessSupervisorMock, :start_game_process, fn _game_id -> {:ok, self()} end)

      expect(GameEventsListenerSupervisorMock, :start_game_events_listener, fn _game_id -> :ok end)

      expect(GameEventLogsListenerSupervisorMock, :start_game_event_logs_listener, fn _game_id ->
        :ok
      end)

      expect(GameTickerSupervisorMock, :start_game_ticker, fn _game_id -> :ok end)

      :ok =
        ResourceManager.start_up(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      verify!()
    end
  end

  describe "shut_down/1" do
    test "stops GameTicker first, then listeners, then GameProcess last" do
      game_id = "some-game-id"
      {:ok, call_order} = Agent.start_link(fn -> [] end)

      expect(GameTickerSupervisorMock, :stop_game_ticker, fn _game_id ->
        Agent.update(call_order, &(&1 ++ [:game_ticker]))
        :ok
      end)

      expect(GameEventsListenerSupervisorMock, :stop_game_events_listener, fn _game_id ->
        Agent.update(call_order, &(&1 ++ [:game_events_listener]))
        :ok
      end)

      expect(GameEventLogsListenerSupervisorMock, :stop_game_event_logs_listener, fn _game_id ->
        Agent.update(call_order, &(&1 ++ [:game_event_logs_listener]))
        :ok
      end)

      expect(GameProcessSupervisorMock, :stop_game_process, fn _game_id ->
        Agent.update(call_order, &(&1 ++ [:game_process]))
        :ok
      end)

      :ok =
        ResourceManager.shut_down(
          game_id,
          GameEventsListenerSupervisorMock,
          GameEventLogsListenerSupervisorMock,
          GameTickerSupervisorMock,
          GameProcessSupervisorMock
        )

      assert Agent.get(call_order, & &1) == [
               :game_ticker,
               :game_events_listener,
               :game_event_logs_listener,
               :game_process
             ]

      Agent.stop(call_order)
      verify!()
    end
  end
end
