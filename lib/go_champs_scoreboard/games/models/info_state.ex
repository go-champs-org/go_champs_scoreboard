defmodule GoChampsScoreboard.Games.Models.InfoState do
  @derive [Poison.Encoder]
  @moduledoc """
  Contains game-related metadata such as dates, times, and tournament information.
  """

  @type t :: %__MODULE__{
          datetime: DateTime.t(),
          tournament_id: String.t(),
          tournament_name: String.t(),
          tournament_slug: String.t(),
          organization_name: String.t(),
          organization_slug: String.t(),
          organization_logo_url: String.t(),
          location: String.t(),
          number: String.t(),
          game_report: String.t()
        }

  defstruct [
    :datetime,
    :tournament_id,
    :tournament_name,
    :tournament_slug,
    :organization_name,
    :organization_slug,
    :organization_logo_url,
    :location,
    :number,
    :game_report
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
      tournament_slug: Keyword.get(opts, :tournament_slug, ""),
      organization_name: Keyword.get(opts, :organization_name, ""),
      organization_slug: Keyword.get(opts, :organization_slug, ""),
      organization_logo_url: Keyword.get(opts, :organization_logo_url, ""),
      location: Keyword.get(opts, :location, ""),
      number: Keyword.get(opts, :number, ""),
      game_report: Keyword.get(opts, :game_report, "")
    }
  end

  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.InfoState do
    def decode(values, _options) do
      datetime =
        case Map.get(values, :datetime) || Map.get(values, "datetime") do
          nil ->
            DateTime.utc_now()

          datetime_str ->
            case DateTime.from_iso8601(datetime_str) do
              {:ok, parsed_datetime, _} -> parsed_datetime
              {:error, _} -> DateTime.utc_now()
            end
        end

      %GoChampsScoreboard.Games.Models.InfoState{
        datetime: datetime,
        tournament_id: Map.get(values, :tournament_id) || Map.get(values, "tournament_id") || "",
        tournament_name:
          Map.get(values, :tournament_name) || Map.get(values, "tournament_name") || "",
        tournament_slug:
          Map.get(values, :tournament_slug) || Map.get(values, "tournament_slug") || "",
        organization_name:
          Map.get(values, :organization_name) || Map.get(values, "organization_name") || "",
        organization_slug:
          Map.get(values, :organization_slug) || Map.get(values, "organization_slug") || "",
        organization_logo_url:
          Map.get(values, :organization_logo_url) || Map.get(values, "organization_logo_url") ||
            "",
        location: Map.get(values, :location) || Map.get(values, "location") || "",
        number: Map.get(values, :number) || Map.get(values, "number") || "",
        game_report: Map.get(values, :game_report) || Map.get(values, "game_report") || ""
      }
    end
  end
end
