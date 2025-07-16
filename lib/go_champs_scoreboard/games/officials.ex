defmodule GoChampsScoreboard.Games.Officials do
  alias GoChampsScoreboard.Games.Models.OfficialState

  @doc """
  Bootstraps a new official with the given name and type.
  Generates a unique ID and sets optional license_number and federation.
  """
  @spec bootstrap(String.t(), String.t()) :: GameOfficialState.t()
  def bootstrap(name, type) when is_binary(name) and is_binary(type) do
    bootstrap(name, type, nil, nil)
  end

  @spec bootstrap(String.t(), String.t(), String.t() | nil) :: GameOfficialState.t()
  def bootstrap(name, type, license_number) when is_binary(name) and is_binary(type) do
    bootstrap(name, type, license_number, nil)
  end

  @spec bootstrap(String.t(), String.t(), String.t() | nil, String.t() | nil) ::
          OfficialState.t()
  def bootstrap(name, type, license_number, federation)
      when is_binary(name) and is_binary(type) do
    type_atom = String.to_existing_atom(type)

    Ecto.UUID.generate()
    |> OfficialState.new(name, type_atom, license_number, federation)
  end
end
