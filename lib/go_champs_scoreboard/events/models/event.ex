defmodule GoChampsScoreboard.Events.Models.Event do
  @type t :: %__MODULE__{
          key: String.t(),
          game_id: String.t(),
          timestamp: DateTime.t(),
          clock_state_time_at: integer(),
          clock_state_period_at: integer(),
          payload: any()
        }

  defstruct [:key, :game_id, :timestamp, :clock_state_time_at, :clock_state_period_at, :payload]

  @spec new(String.t(), String.t(), integer(), integer()) :: t()
  @spec new(String.t(), String.t(), integer(), integer(), any()) :: t()
  def new(key, game_id, clock_state_time_at, clock_state_period_at, payload \\ nil) do
    %__MODULE__{
      key: key,
      game_id: game_id,
      timestamp: DateTime.utc_now(),
      clock_state_time_at: clock_state_time_at,
      clock_state_period_at: clock_state_period_at,
      payload: payload
    }
  end
end
