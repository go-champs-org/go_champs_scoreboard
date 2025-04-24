defmodule GoChampsScoreboard.Events.Models.Event do
  @type meta :: %{
          persistable: boolean()
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
        meta \\ %{persistable: true},
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
