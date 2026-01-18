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
  The level at which a stat is calculated.

  Player-level stats are calculated using only the player's data.
  Team-level stats are calculated using the team's data.
  Game-level stats are calculated using the full game state and event context.
  """
  @type stat_level :: :player | :team | :game

  @typedoc """
  The type of operation that can be performed on the stat, such as incrementing or decrementing its value.
  These operations define how the stat can be modified during the game.
  """
  @type operation_type :: :increment | :decrement
  @typedoc """
  The function used to calculate the value of a calculated stat.
  For player-level stats: takes PlayerState and returns a float value.
  For team-level stats: takes TeamState and returns a float value.
  For game-level stats: takes (PlayerState, GameState, team_type, stat_id, operation, event_team_type) and returns a float value.
  If the stat is manual or automatic, this function can be nil.
  """
  @type calculation_function() ::
          (PlayerState.t() | TeamState.t() -> float())
          | (PlayerState.t(), any(), String.t(), String.t(), String.t(), String.t() -> float())
          | nil

  @type t :: %__MODULE__{
          key: String.t(),
          type: type,
          level: stat_level,
          operations: [operation_type],
          calculation_function: calculation_function
        }

  defstruct [:key, :type, :level, :operations, :calculation_function]

  @spec new(String.t(), type(), [operation_type()], calculation_function(), stat_level()) :: t()
  def new(key, type, operations \\ [:inc, :dec], calculation_function \\ nil, level \\ :player) do
    %__MODULE__{
      key: key,
      type: type,
      level: level,
      operations: operations,
      calculation_function: calculation_function
    }
  end
end
