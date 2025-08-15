defmodule GoChampsScoreboard.Events.Models.Event do
  @moduledoc """
  Event model for representing game events.

  The `persistable` field indicates whether the event should be stored in the database.

  The `logs_reduce_behavior` in meta controls how events are processed during log reduction:
  - `:handle` - Process the event normally through its specific handler
  - `:copy_all_stats_from_game_state` - Copy all stats from source game state instead of handling
  """

  @type logs_reduce_behavior :: :handle | :copy_all_stats_from_game_state

  @type meta :: %{
          persistable: boolean(),
          logs_reduce_behavior: logs_reduce_behavior()
        }

  @type t :: %__MODULE__{
          meta: meta(),
          key: String.t(),
          game_id: String.t(),
          timestamp: DateTime.t(),
          clock_state_time_at: integer(),
          clock_state_period_at: integer(),
          payload: any()
        }

  defstruct [
    :meta,
    :key,
    :game_id,
    :timestamp,
    :clock_state_time_at,
    :clock_state_period_at,
    :payload
  ]

  @spec new(String.t(), String.t(), integer(), integer()) :: t()
  @spec new(String.t(), String.t(), integer(), integer(), any()) :: t()
  @spec new(String.t(), String.t(), integer(), integer(), any(), DateTime.t()) :: t()
  @spec new(String.t(), String.t(), integer(), integer(), any(), meta(), DateTime.t()) :: t()
  def new(
        key,
        game_id,
        clock_state_time_at,
        clock_state_period_at,
        payload \\ nil,
        meta \\ %{persistable: true, logs_reduce_behavior: :handle},
        timestamp \\ DateTime.utc_now()
      ) do
    %__MODULE__{
      key: key,
      game_id: game_id,
      clock_state_time_at: clock_state_time_at,
      clock_state_period_at: clock_state_period_at,
      payload: payload,
      meta: meta,
      timestamp: timestamp
    }
  end
end
