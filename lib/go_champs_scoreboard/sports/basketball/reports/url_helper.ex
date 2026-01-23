defmodule GoChampsScoreboard.Sports.Basketball.Reports.UrlHelper do
  @moduledoc """
  Helper functions for URL manipulation in basketball reports.
  """

  @doc """
  Extracts the path portion from a URL.

  If the URL contains "go-champs.com" or "example.com", returns only the path
  (e.g., "/media/PATH"). Otherwise, returns the original value.

  ## Examples

      iex> extract_path_from_url("https://go-champs.com/media/logo.png")
      "/media/logo.png"

      iex> extract_path_from_url("http://example.com/assets/image.jpg")
      "/assets/image.jpg"

      iex> extract_path_from_url("https://other-site.com/logo.png")
      "https://other-site.com/logo.png"

      iex> extract_path_from_url(nil)
      nil

      iex> extract_path_from_url("")
      ""
  """
  @spec extract_path_from_url(String.t() | nil) :: String.t() | nil
  def extract_path_from_url(nil), do: nil
  def extract_path_from_url(""), do: ""

  def extract_path_from_url(url) do
    case URI.parse(url) do
      %URI{host: host, path: path} when is_binary(host) and is_binary(path) ->
        if String.contains?(host, "go-champs.com") or String.contains?(host, "example.com") do
          path
        else
          url
        end

      _ ->
        url
    end
  end
end
