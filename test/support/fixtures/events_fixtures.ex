defmodule GoChampsScoreboard.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoChampsScoreboard.Events` context.
  """

  alias GoChampsScoreboard.Games.EventLogs
  import GoChampsScoreboard.GameStateFixtures

  @doc """
  Generate a event_log.
  """
  def event_log_fixture(attrs \\ %{}) do
    {:ok, event_log} =
      attrs
      |> Enum.into(%{
        game_id: "7488a646-e31f-11e4-aace-600308960662",
        key: "some key",
        payload: %{},
        timestamp: ~U[2025-04-21 00:39:00.000000Z],
        game_clock_time: 10,
        game_clock_period: 1
      })
      |> GoChampsScoreboard.Events.create_event_log()

    event_log
  end

  @doc """
  Generate a event_log with a snapshot.
  """
  def event_log_with_snapshot_fixture(_attrs \\ %{}) do
    game_state = game_state_fixture()

    start_live_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        10,
        1,
        %{}
      )

    {:ok, event_log} = EventLogs.persist(start_live_event, game_state)

    event_log
  end
end
