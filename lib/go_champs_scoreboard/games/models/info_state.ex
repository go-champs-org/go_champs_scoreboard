defmodule GoChampsScoreboard.Games.Models.InfoState do
  @derive [Poison.Encoder]
  @moduledoc """
  Contains game-related metadata such as dates, times, and tournament information.
  """

  @type t :: %__MODULE__{
          datetime: DateTime.t(),
          actual_start_datetime: DateTime.t() | nil,
          actual_end_datetime: DateTime.t() | nil,
          tournament_id: String.t(),
          tournament_name: String.t(),
          location: String.t()
        }

  defstruct [
    :datetime,
    :actual_start_datetime,
    :actual_end_datetime,
    :tournament_id,
    :tournament_name,
    :location
  ]

  @doc """
  Creates a new InfoState struct with the given datetime and optional parameters.
  """
  @spec new(DateTime.t(), keyword()) :: t()
  def new(datetime, opts \\ []) do
    %__MODULE__{
      datetime: datetime,
      actual_start_datetime: Keyword.get(opts, :actual_start_datetime),
      actual_end_datetime: Keyword.get(opts, :actual_end_datetime),
      tournament_id: Keyword.get(opts, :tournament_id, ""),
      tournament_name: Keyword.get(opts, :tournament_name, ""),
      location: Keyword.get(opts, :location, "")
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.InfoState do
    def decode(
          %{
            datetime: datetime,
            actual_start_datetime: actual_start_datetime,
            actual_end_datetime: actual_end_datetime,
            tournament_id: tournament_id,
            tournament_name: tournament_name,
            location: location
          } = _values,
          _options
        ) do
      datetime = Date.from_iso8601!(datetime)

      actual_start_datetime =
        if actual_start_datetime do
          DateTime.from_iso8601(actual_start_datetime)
          |> elem(1)
        else
          nil
        end

      actual_end_datetime =
        if actual_end_datetime do
          DateTime.from_iso8601(actual_end_datetime)
          |> elem(1)
        else
          nil
        end

      %GoChampsScoreboard.Games.Models.InfoState{
        datetime: datetime,
        actual_start_datetime: actual_start_datetime,
        actual_end_datetime: actual_end_datetime,
        tournament_id: tournament_id,
        tournament_name: tournament_name,
        location: location
      }
    end
  end
end
