defmodule GoChampsScoreboard.Games.Coaches do
  alias GoChampsScoreboard.Games.Models.CoachState

  @spec bootstrap(String.t(), CoachState.type()) :: CoachState.t()
  def bootstrap(name, type) do
    Ecto.UUID.generate()
    |> CoachState.new(name, type)
  end
end
