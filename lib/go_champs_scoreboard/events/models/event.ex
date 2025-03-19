defmodule GoChampsScoreboard.Events.Models.Event do
  @type t :: %__MODULE__{
          key: String.t(),
          game_id: String.t(),
          timestamp: DateTime.t(),
          payload: any(),
          impact_temporal_stats: boolean()
        }

  defstruct [:key, :game_id, :timestamp, :payload, :impact_temporal_stats]

  @spec new(String.t(), String.t()) :: t()
  @spec new(String.t(), String.t(), any()) :: t()
  def new(key, game_id, payload \\ nil, impact_temporal_stats \\ false) do
    %__MODULE__{
      key: key,
      game_id: game_id,
      timestamp: DateTime.utc_now(),
      payload: payload,
      impact_temporal_stats: impact_temporal_stats
    }
  end
end
