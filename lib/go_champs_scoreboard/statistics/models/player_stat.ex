defmodule GoChampsScoreboard.Statistics.Models.PlayerStat do
  alias GoChampsScoreboard.Games.Models.PlayerState

  @type type :: :manual | :calculated
  @type operation_type :: :increment | :decrement
  @type calculation_function() :: (PlayerState.t() -> float()) | nil

  @type t :: %__MODULE__{
          key: String.t(),
          type: type,
          operations: [operation_type],
          calculation_function: calculation_function
        }

  defstruct [:key, :type, :operations, :calculation_function]

  @spec new(String.t(), type(), calculation_function()) :: t()
  def new(key, type, operations \\ [:inc, :dec], calculation_function \\ nil) do
    %__MODULE__{
      key: key,
      type: type,
      operations: operations,
      calculation_function: calculation_function
    }
  end
end
