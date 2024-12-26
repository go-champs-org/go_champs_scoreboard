defmodule GoChampsScoreboard.Games.BootstrapperTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Games.Bootstrapper

  import Mox

  describe "bootstrap" do
    test "bootstraps with random game-id" do
      game = Bootstrapper.bootstrap()
      assert String.length(game.id) > 0
    end

    test "bootstraps with home team and away team" do
      game = Bootstrapper.bootstrap()
      assert game.away_team.name == "Away team"
      assert game.away_team.players == []
      assert game.away_team.total_player_stats == %{}
      assert game.home_team.name == "Home team"
      assert game.home_team.players == []
      assert game.home_team.total_player_stats == %{}
    end
  end

  describe "bootstrap_from_api" do
    @http_client GoChampsScoreboard.HTTPClientMock
    @response_body %{
      "data" => %{
        "id" => "game-id",
        "away_team" => %{
          "name" => "Team A",
          "players" => [
            %{
              "id" => "player-1",
              "name" => "Player 1",
              "number" => 1
            },
            %{
              "id" => "player-2",
              "name" => "Player 2"
            },
            %{
              "id" => "player-3",
              "name" => "Player 3",
              "number" => 3
            },
            %{
              "id" => "player-4",
              "name" => "Player 4"
            },
            %{
              "id" => "player-5",
              "name" => "Player 5",
              "number" => 5
            },
            %{
              "id" => "player-6",
              "name" => "Player 6"
            }
          ]
        },
        "home_team" => %{
          "name" => "Team B",
          "players" => [
            %{
              "id" => "player-7",
              "name" => "Player 7",
              "number" => 7
            },
            %{
              "id" => "player-8",
              "name" => "Player 8"
            },
            %{
              "id" => "player-9",
              "name" => "Player 9",
              "number" => 9
            },
            %{
              "id" => "player-10",
              "name" => "Player 10"
            },
            %{
              "id" => "player-11",
              "name" => "Player 11",
              "number" => 11
            },
            %{
              "id" => "player-12",
              "name" => "Player 12"
            }
          ]
        }
      }
    }

    test "maps game id" do
      expect(@http_client, :get, fn url, headers ->
        assert url =~ "game-id"
        assert headers == [{"Authorization", "Bearer token"}]

        {:ok, %HTTPoison.Response{body: @response_body |> Poison.encode!(), status_code: 200}}
      end)

      game =
        Bootstrapper.bootstrap_from_go_champs(
          GoChampsScoreboard.Games.Bootstrapper.bootstrap(),
          "game-id",
          "token"
        )

      [player_1, player_2, player_3, player_4, player_5, player_6] = game.away_team.players
      assert game.id == "game-id"
      assert game.away_team.name == "Team A"
      assert player_1.id == "player-1"
      assert player_1.name == "Player 1"
      assert player_1.number == 1
      assert player_1.state == :playing
      assert player_2.id == "player-2"
      assert player_2.name == "Player 2"
      assert player_2.number == nil
      assert player_2.state == :playing
      assert player_3.id == "player-3"
      assert player_3.name == "Player 3"
      assert player_3.number == 3
      assert player_3.state == :playing
      assert player_4.id == "player-4"
      assert player_4.name == "Player 4"
      assert player_4.number == nil
      assert player_4.state == :playing
      assert player_5.id == "player-5"
      assert player_5.name == "Player 5"
      assert player_5.number == 5
      assert player_5.state == :playing
      assert player_6.id == "player-6"
      assert player_6.name == "Player 6"
      assert player_6.number == nil
      assert player_6.state == :available
      assert game.away_team.total_player_stats == %{}

      [player_7, player_8, player_9, player_10, player_11, player_12] = game.home_team.players
      assert game.home_team.name == "Team B"
      assert player_7.id == "player-7"
      assert player_7.name == "Player 7"
      assert player_7.number == 7
      assert player_7.state == :playing
      assert player_8.id == "player-8"
      assert player_8.name == "Player 8"
      assert player_8.number == nil
      assert player_8.state == :playing
      assert player_9.id == "player-9"
      assert player_9.name == "Player 9"
      assert player_9.number == 9
      assert player_9.state == :playing
      assert player_10.id == "player-10"
      assert player_10.name == "Player 10"
      assert player_10.number == nil
      assert player_10.state == :playing
      assert player_11.id == "player-11"
      assert player_11.name == "Player 11"
      assert player_11.number == 11
      assert player_11.state == :playing
      assert player_12.id == "player-12"
      assert player_12.name == "Player 12"
      assert player_12.number == nil
      assert player_12.state == :available
      assert game.home_team.total_player_stats == %{}
    end
  end
end
