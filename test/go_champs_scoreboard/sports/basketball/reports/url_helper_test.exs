defmodule GoChampsScoreboard.Sports.Basketball.Reports.UrlHelperTest do
  use ExUnit.Case, async: true

  alias GoChampsScoreboard.Sports.Basketball.Reports.UrlHelper

  describe "extract_path_from_url/1" do
    test "extracts path from go-champs.com URL" do
      assert UrlHelper.extract_path_from_url("https://go-champs.com/media/logo.png") ==
               "/media/logo.png"

      assert UrlHelper.extract_path_from_url("http://go-champs.com/assets/image.jpg") ==
               "/assets/image.jpg"
    end

    test "extracts path from example.com URL" do
      assert UrlHelper.extract_path_from_url("http://example.com/media/logo.png") ==
               "/media/logo.png"

      assert UrlHelper.extract_path_from_url("https://example.com/path/to/file.png") ==
               "/path/to/file.png"
    end

    test "returns original URL for other domains" do
      assert UrlHelper.extract_path_from_url("https://other-site.com/logo.png") ==
               "https://other-site.com/logo.png"

      assert UrlHelper.extract_path_from_url("http://another-domain.org/image.jpg") ==
               "http://another-domain.org/image.jpg"
    end

    test "handles nil value" do
      assert UrlHelper.extract_path_from_url(nil) == nil
    end

    test "handles empty string" do
      assert UrlHelper.extract_path_from_url("") == ""
    end

    test "handles relative paths" do
      assert UrlHelper.extract_path_from_url("/media/logo.png") == "/media/logo.png"
      assert UrlHelper.extract_path_from_url("media/logo.png") == "media/logo.png"
    end

    test "handles URLs without path" do
      assert UrlHelper.extract_path_from_url("https://go-champs.com") == "https://go-champs.com"
    end
  end
end
