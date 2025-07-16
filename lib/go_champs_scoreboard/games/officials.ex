defmodule GoChampsScoreboard.Games.Officials do
  alias GoChampsScoreboard.Games.Models.OfficialState

  @spec bootstrap(String.t(), String.t()) :: OfficialState.t()
  def bootstrap(name, type) do
    type_atom = String.to_existing_atom(type)

    Ecto.UUID.generate()
    |> OfficialState.new(name, type_atom)
  end
end
