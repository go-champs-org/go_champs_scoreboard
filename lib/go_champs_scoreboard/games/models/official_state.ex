defmodule GoChampsScoreboard.Games.Models.OfficialState do
  @moduledoc """
  Represents a game official in the scoreboard system.
  """

  @type official_type ::
          :scorer
          | :assistant_scorer
          | :timekeeper
          | :shot_clock_operator
          | :crew_chief
          | :umpire_1
          | :umpire_2

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          type: official_type(),
          license_number: String.t() | nil,
          federation: String.t() | nil,
          signature: String.t() | nil,
          username: String.t() | nil
        }

  defstruct [
    :id,
    :name,
    :type,
    :license_number,
    :federation,
    :signature,
    :username
  ]

  @doc """
  Creates a new OfficialState
  """
  @spec new(
          String.t(),
          String.t(),
          official_type(),
          String.t() | nil,
          String.t() | nil,
          String.t() | nil,
          String.t() | nil
        ) :: t()
  def new(
        id,
        name,
        type,
        license_number \\ nil,
        federation \\ nil,
        signature \\ nil,
        username \\ nil
      ) do
    %__MODULE__{
      id: id,
      name: name,
      type: type,
      license_number: license_number,
      federation: federation,
      signature: signature,
      username: username
    }
  end

  @doc """
  Returns all valid official types
  """
  @spec valid_types() :: [official_type()]
  def valid_types do
    [
      :scorer,
      :assistant_scorer,
      :timekeeper,
      :shot_clock_operator,
      :crew_chief,
      :umpire_1,
      :umpire_2
    ]
  end

  @doc """
  Returns a human-readable name for an official type
  """
  @spec type_display_name(official_type()) :: String.t()
  def type_display_name(:scorer), do: "Scorer"
  def type_display_name(:assistant_scorer), do: "Assistant Scorer"
  def type_display_name(:timekeeper), do: "Timekeeper"
  def type_display_name(:shot_clock_operator), do: "Shot Clock Operator"
  def type_display_name(:crew_chief), do: "Crew Chief"
  def type_display_name(:umpire_1), do: "Umpire 1"
  def type_display_name(:umpire_2), do: "Umpire 2"

  @doc """
  Validates if a type is valid
  """
  @spec valid_type?(atom()) :: boolean()
  def valid_type?(type) do
    type in valid_types()
  end

  @doc """
  Safely converts a type value to a valid official type atom.

  Handles:
  - nil → :crew_chief (default for legacy payloads)
  - atom → validates and returns if valid, otherwise :crew_chief
  - string → safely converts to atom if it's a known type, otherwise :crew_chief

  This prevents atom table exhaustion DoS attacks by only accepting known types.
  """
  @spec normalize_type(any()) :: official_type()
  def normalize_type(nil), do: :crew_chief

  def normalize_type(type) when is_atom(type) do
    if valid_type?(type), do: type, else: :crew_chief
  end

  def normalize_type(type) when is_binary(type) do
    case safe_string_to_atom(type) do
      {:ok, atom_type} -> if valid_type?(atom_type), do: atom_type, else: :crew_chief
      :error -> :crew_chief
    end
  end

  def normalize_type(_), do: :crew_chief

  @doc false
  @spec safe_string_to_atom(String.t()) :: {:ok, atom()} | :error
  defp safe_string_to_atom(string) do
    try do
      {:ok, String.to_existing_atom(string)}
    catch
      :error, :badarg -> :error
    end
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.OfficialState do
    def decode(
          %{
            id: id,
            name: name,
            type: type,
            license_number: license_number,
            federation: federation,
            signature: signature,
            username: username
          } = _value,
          _options
        ) do
      %GoChampsScoreboard.Games.Models.OfficialState{
        type: if(is_nil(type), do: :crew_chief, else: String.to_atom(type)),
        id: id,
        name: name,
        license_number: license_number,
        federation: federation,
        signature: signature,
        username: username
      }
    end
  end
end
