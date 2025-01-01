defmodule GoChampsScoreboard.Games.Models.PlayerState do
  alias GoChampsScoreboard.Sports.Basketball.Basketball

  @type state :: :playing | :bench | :injured | :suspended | :available | :not_available

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          number: String.t(),
          state: state(),
          stats_values: map()
        }
  defstruct [:id, :name, :number, :state, :stats_values]

  @spec new(String.t(), String.t(), String.t(), state(), map()) :: t()
  def new(id, name, number \\ "0", state \\ :available, stats_values \\ Basketball.bootstrap()) do
    %__MODULE__{
      id: id,
      name: name,
      number: number,
      state: state,
      stats_values: stats_values
    }
  end
end
