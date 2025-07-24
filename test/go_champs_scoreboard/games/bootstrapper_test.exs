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
          "tri_code" => "ABC",
          "logo_url" => "https://example.com/logo.png",
          "players" => [
            %{
              "id" => "player-1",
              "name" => "Player 1",
              "shirt_name" => "P 1",
              "shirt_number" => "1"
            },
            %{
              "id" => "player-2",
              "name" => "Player 2",
              "shirt_number" => "2"
            },
            %{
              "id" => "player-3",
              "name" => "Player 3",
              "shirt_name" => "P 3"
            },
            %{
              "id" => "player-4",
              "name" => "Player 4"
            },
            %{
              "id" => "player-5",
              "name" => "Player 5"
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
              "shirt_name" => "P 7",
              "shirt_number" => "7"
            },
            %{
              "id" => "player-8",
              "name" => "Player 8",
              "shirt_number" => "8"
            },
            %{
              "id" => "player-9",
              "name" => "Player 9",
              "shirt_name" => "P 9"
            },
            %{
              "id" => "player-10",
              "name" => "Player 10"
            },
            %{
              "id" => "player-11",
              "name" => "Player 11"
            },
            %{
              "id" => "player-12",
              "name" => "Player 12"
            }
          ]
        },
        "live_state" => "ended"
      }
    }
    @response_body_with_coaches %{
      "data" => %{
        "id" => "game-id",
        "away_team" => %{
          "name" => "Team A",
          "tri_code" => "ABC",
          "logo_url" => "https://example.com/logo.png",
          "players" => [
            %{
              "id" => "player-1",
              "name" => "Player 1",
              "shirt_name" => "P 1",
              "shirt_number" => "1"
            }
          ],
          "coaches" => [
            %{
              "id" => "coach-1",
              "name" => "Coach 1",
              "type" => "head_coach",
              "state" => "available"
            },
            %{
              "id" => "coach-2",
              "name" => "Coach 2",
              "type" => "assistant_coach"
            }
          ]
        },
        "home_team" => %{
          "name" => "Team B",
          "players" => [
            %{
              "id" => "player-2",
              "name" => "Player 2",
              "shirt_name" => "P 2",
              "shirt_number" => "2"
            }
          ],
          "coaches" => [
            %{
              "id" => "coach-3",
              "name" => "Coach 3",
              "type" => "head_coach",
              "state" => "not_available"
            },
            %{
              "id" => "coach-4",
              "name" => "Coach 4",
              "type" => "assistant_coach",
              "state" => "available"
            }
          ]
        },
        "live_state" => "ended"
      }
    }
    @response_body_with_info %{
      "data" => %{
        "id" => "game-id",
        "away_team" => %{
          "name" => "Team A",
          "tri_code" => "ABC",
          "logo_url" => "https://example.com/logo.png",
          "players" => [
            %{
              "id" => "player-1",
              "name" => "Player 1",
              "shirt_name" => "P 1",
              "shirt_number" => "1"
            }
          ]
        },
        "home_team" => %{
          "name" => "Team B",
          "players" => [
            %{
              "id" => "player-2",
              "name" => "Player 2",
              "shirt_name" => "P 2",
              "shirt_number" => "2"
            }
          ]
        },
        "datetime" => "2023-10-01T12:00:00Z",
        "location" => "Stadium A",
        "phase" => %{
          "tournament" => %{
            "id" => "tournament-id",
            "name" => "Tournament Name"
          }
        }
      }
    }

    @response_setting_body %{
      "data" => %{
        "view" => "basketball-basic"
      }
    }

    test "maps game id" do
      expect(@http_client, :get, fn url, headers ->
        assert url =~ "game-id"
        assert headers == [{"Authorization", "Bearer token"}]

        {:ok, %HTTPoison.Response{body: @response_body |> Poison.encode!(), status_code: 200}}
      end)

      expect(@http_client, :get, fn url ->
        assert url =~ "game-id/scoreboard-setting"

        {:ok, %HTTPoison.Response{body: %{"data" => nil} |> Poison.encode!(), status_code: 200}}
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
      assert player_1.name == "P 1"
      assert player_1.number == "1"
      assert player_1.state == :available
      assert player_2.id == "player-2"
      assert player_2.name == "Player 2"
      assert player_2.number == "2"
      assert player_2.state == :available
      assert player_3.id == "player-3"
      assert player_3.name == "P 3"
      assert player_3.number == nil
      assert player_3.state == :available
      assert player_4.id == "player-4"
      assert player_4.name == "Player 4"
      assert player_4.number == nil
      assert player_4.state == :available
      assert player_5.id == "player-5"
      assert player_5.name == "Player 5"
      assert player_5.number == nil
      assert player_5.state == :available
      assert player_6.id == "player-6"
      assert player_6.name == "Player 6"
      assert player_6.number == nil
      assert player_6.state == :available
      assert game.away_team.total_player_stats == %{}
      assert game.away_team.tri_code == "ABC"
      assert game.away_team.logo_url == "https://example.com/logo.png"

      [player_7, player_8, player_9, player_10, player_11, player_12] = game.home_team.players
      assert game.home_team.name == "Team B"
      assert player_7.id == "player-7"
      assert player_7.name == "P 7"
      assert player_7.number == "7"
      assert player_7.state == :available
      assert player_8.id == "player-8"
      assert player_8.name == "Player 8"
      assert player_8.number == "8"
      assert player_8.state == :available
      assert player_9.id == "player-9"
      assert player_9.name == "P 9"
      assert player_9.number == nil
      assert player_9.state == :available
      assert player_10.id == "player-10"
      assert player_10.name == "Player 10"
      assert player_10.number == nil
      assert player_10.state == :available
      assert player_11.id == "player-11"
      assert player_11.name == "Player 11"
      assert player_11.number == nil
      assert player_11.state == :available
      assert player_12.id == "player-12"
      assert player_12.name == "Player 12"
      assert player_12.number == nil
      assert player_12.state == :available
      assert game.home_team.total_player_stats == %{}
      assert game.home_team.tri_code == ""
      assert game.home_team.logo_url == ""

      assert game.live_state.state == :ended
      assert game.sport_id == "basketball"
      assert game.view_settings_state.view == "basketball-medium"
    end

    test "maps game and view settings" do
      expect(@http_client, :get, fn url, headers ->
        assert url =~ "game-id"
        assert headers == [{"Authorization", "Bearer token"}]

        {:ok, %HTTPoison.Response{body: @response_body |> Poison.encode!(), status_code: 200}}
      end)

      expect(@http_client, :get, fn url ->
        assert url =~ "game-id/scoreboard-setting"

        {:ok,
         %HTTPoison.Response{body: @response_setting_body |> Poison.encode!(), status_code: 200}}
      end)

      game =
        Bootstrapper.bootstrap_from_go_champs(
          GoChampsScoreboard.Games.Bootstrapper.bootstrap(),
          "game-id",
          "token"
        )

      assert game.sport_id == "basketball"
      assert game.view_settings_state.view == "basketball-basic"
    end

    test "maps game and team coaches" do
      expect(@http_client, :get, fn url, headers ->
        assert url =~ "game-id"
        assert headers == [{"Authorization", "Bearer token"}]

        {:ok,
         %HTTPoison.Response{
           body: @response_body_with_coaches |> Poison.encode!(),
           status_code: 200
         }}
      end)

      expect(@http_client, :get, fn url ->
        assert url =~ "game-id/scoreboard-setting"

        {:ok, %HTTPoison.Response{body: %{"data" => nil} |> Poison.encode!(), status_code: 200}}
      end)

      game =
        Bootstrapper.bootstrap_from_go_champs(
          GoChampsScoreboard.Games.Bootstrapper.bootstrap(),
          "game-id",
          "token"
        )

      [coach_1, coach_2] = game.away_team.coaches
      assert coach_1.id == "coach-1"
      assert coach_1.name == "Coach 1"
      assert coach_1.type == :head_coach
      assert coach_1.state == :available
      assert coach_2.id == "coach-2"
      assert coach_2.name == "Coach 2"
      assert coach_2.type == :assistant_coach
      assert coach_2.state == :available

      [coach_3, coach_4] = game.home_team.coaches
      assert coach_3.id == "coach-3"
      assert coach_3.name == "Coach 3"
      assert coach_3.type == :head_coach
      assert coach_3.state == :not_available
      assert coach_4.id == "coach-4"
      assert coach_4.name == "Coach 4"
      assert coach_4.type == :assistant_coach
      assert coach_4.state == :available
    end

    test "maps game and info" do
      expect(@http_client, :get, fn url, headers ->
        assert url =~ "game-id"
        assert headers == [{"Authorization", "Bearer token"}]

        {:ok,
         %HTTPoison.Response{
           body: @response_body_with_info |> Poison.encode!(),
           status_code: 200
         }}
      end)

      expect(@http_client, :get, fn url ->
        assert url =~ "game-id/scoreboard-setting"

        {:ok,
         %HTTPoison.Response{body: @response_setting_body |> Poison.encode!(), status_code: 200}}
      end)

      game =
        Bootstrapper.bootstrap_from_go_champs(
          GoChampsScoreboard.Games.Bootstrapper.bootstrap(),
          "game-id",
          "token"
        )

      {:ok, expected_datetime, _} =
        DateTime.from_iso8601("2023-10-01T12:00:00Z")

      assert game.info.datetime == expected_datetime
      assert game.info.tournament_id == "tournament-id"
      assert game.info.tournament_name == "Tournament Name"
      assert game.info.location == "Stadium A"
    end
  end
end
