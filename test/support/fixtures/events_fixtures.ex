defmodule GoChampsScoreboard.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoChampsScoreboard.Events` context.
  """

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
        sequence_number: 42,
        timestamp: ~U[2025-04-21 00:39:00.000000Z]
      })
      |> GoChampsScoreboard.Events.create_event_log()

    event_log
  end
end
