defmodule GoChampsScoreboard.Games.Models.TemporalStatsState do
  @type t :: %__MODULE__{
          stats_values: map()
        }
  defstruct [:stats_values]

  @spec new(map()) :: t()
  def new(stats_values) do
    %__MODULE__{
      stats_values: stats_values
    }
  end
end
