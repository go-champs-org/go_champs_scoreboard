defmodule GoChampsScoreboard.ApiClientTest do
  use ExUnit.Case
  alias GoChampsScoreboard.ApiClient

  import Mox

  setup :verify_on_exit!

  @http_client GoChampsScoreboard.HTTPClientMock
  @test_config http_client: @http_client, url: "url.com"

  describe "get_game" do
    test "returns response from API" do
      response_body = %{
        "id" => "game-id",
        "away_team" => %{
          "name" => "Away team"
        },
        "home_team" => %{
          "name" => "Home team"
        }
      }

      expect(@http_client, :get, fn url, headers ->
        assert url =~ "game-id"
        assert headers == [{"Authorization", "Bearer token"}]

        {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
      end)

      assert {:ok,
              %{
                "id" => "game-id",
                "away_team" => %{
                  "name" => "Away team"
                },
                "home_team" => %{
                  "name" => "Home team"
                }
              }} = ApiClient.get_game("game-id", "token", @test_config)
    end
  end

  describe "get_scoreboard_setting" do
    test "returns response from API" do
      response_body = %{
        "id" => "game-id",
        "view" => "basketbal-basic"
      }

      expect(@http_client, :get, fn url ->
        assert url =~ "game-id/scoreboard-setting"

        {:ok, %HTTPoison.Response{body: response_body |> Poison.encode!(), status_code: 200}}
      end)

      assert {:ok,
              %{
                "id" => "game-id",
                "view" => "basketbal-basic"
              }} = ApiClient.get_scoreboard_setting("game-id", @test_config)
    end
  end
end
