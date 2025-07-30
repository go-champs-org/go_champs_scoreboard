defmodule GoChampsScoreboard.Statistics.Models.Stat do
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.TeamState

  @moduledoc """
  Represents a statistical metric for players or teams in a game.
  Each stat can be of different types, such as manual, calculated, or automatic.
  It can also have associated operations for incrementing or decrementing the stat.
  """

  @typedoc """
  The type of stat, which can be manual, calculated, or automatic.

  Manual stats are directly modified by user actions.
  Manual stats can be overridden by the user or game event logs.
  Calculated stats are derived from other stats or game data.
  Calculated stats can be overridden only by game event logs.
  Automatic stats are updated automatically based on game tick events.
  Automatic stats cannot be overridden because they are calculated by game tick events.
  """
  @type type :: :manual | :calculated | :automatic

  @typedoc """
  The type of operation that can be performed on the stat, such as incrementing or decrementing its value.
  These operations define how the stat can be modified during the game.
  """
  @type operation_type :: :increment | :decrement
  @typedoc """
  The function used to calculate the value of a calculated stat.
  This function takes a PlayerState or TeamState and returns a float value.
  It is used to compute the stat value based on other stats or game data.
  If the stat is manual or automatic, this function can be nil.
  """
  @type calculation_function() :: (PlayerState.t() | TeamState.t() -> float()) | nil

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
