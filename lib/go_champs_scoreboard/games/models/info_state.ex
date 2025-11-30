defmodule GoChampsScoreboard.Games.Models.InfoState do
  @derive [Poison.Encoder]
  @moduledoc """
  Contains game-related metadata such as dates, times, and tournament information.
  """

  @type t :: %__MODULE__{
          datetime: DateTime.t(),
          tournament_id: String.t(),
          tournament_name: String.t(),
          location: String.t(),
          number: String.t()
        }

  defstruct [
    :datetime,
    :tournament_id,
    :tournament_name,
    :location,
    :number
  ]

  @doc """
  Creates a new InfoState struct with the given datetime and optional parameters.
  """
  @spec new(DateTime.t(), keyword()) :: t()
  def new(datetime, opts \\ []) do
    %__MODULE__{
      datetime: datetime,
      tournament_id: Keyword.get(opts, :tournament_id, ""),
      tournament_name: Keyword.get(opts, :tournament_name, ""),
      location: Keyword.get(opts, :location, ""),
      number: Keyword.get(opts, :number, "")
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.InfoState do
    def decode(
          %{
            datetime: datetime,
            tournament_id: tournament_id,
            tournament_name: tournament_name,
            location: location,
            number: number
          } = _values,
          _options
        ) do
      datetime =
        if datetime do
          case DateTime.from_iso8601(datetime) do
            {:ok, parsed_datetime, _} -> parsed_datetime
            {:error, _} -> DateTime.utc_now()
          end
        else
          DateTime.utc_now()
        end

      %GoChampsScoreboard.Games.Models.InfoState{
        datetime: datetime,
        tournament_id: tournament_id,
        tournament_name: tournament_name,
        location: location,
        number: number
      }
    end
  end
end
