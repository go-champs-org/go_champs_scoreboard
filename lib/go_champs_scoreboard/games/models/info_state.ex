defmodule GoChampsScoreboard.Games.Models.InfoState do
  @derive [Poison.Encoder]
  @moduledoc """
  Contains game-related metadata such as dates, times, and tournament information.
  """

  @type result_type :: :automatic | :home_team_walkover | :away_team_walkover

  @type asset :: %{
          type: String.t(),
          url: String.t()
        }

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
          game_report: String.t(),
          web_url: String.t(),
          result_type: result_type(),
          assets: [asset()]
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
    :game_report,
    :web_url,
    :result_type,
    :assets
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
      game_report: Keyword.get(opts, :game_report, ""),
      web_url: Keyword.get(opts, :web_url, ""),
      result_type: Keyword.get(opts, :result_type, :automatic),
      assets: Keyword.get(opts, :assets, [])
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

      result_type =
        case Map.get(values, :result_type) || Map.get(values, "result_type") do
          "home_team_walkover" -> :home_team_walkover
          "away_team_walkover" -> :away_team_walkover
          _ -> :automatic
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
        game_report: Map.get(values, :game_report) || Map.get(values, "game_report") || "",
        web_url: Map.get(values, :web_url) || Map.get(values, "web_url") || "",
        result_type: result_type,
        assets: Map.get(values, :assets) || Map.get(values, "assets") || []
      }
    end
  end
end
