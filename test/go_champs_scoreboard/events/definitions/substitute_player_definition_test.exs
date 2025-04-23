defmodule GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Games.Models.{GameState, TeamState, PlayerState}

  alias GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinition
  alias GoChampsScoreboard.Events.Models.Event

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{}

      assert {:ok} =
               SubstitutePlayerDefinition.validate(game_state, %{})
    end
  end

  describe "create/2" do
    test "returns event" do
      assert %Event{
               key: "substitute-player",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               SubstitutePlayerDefinition.create("some-game-id", 10, 1, %{
                 "team-type" => "home",
                 "playing-player-id" => "some-id",
                 "bench-player-id" => "some-other-id"
               })
    end
  end

  describe "handle/2" do
    test "returns game state with updated player state" do
      game_state = %GameState{
        away_team: %TeamState{
          players: [
            %PlayerState{
              id: "some-id",
              state: :playing,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            },
            %PlayerState{
              id: "some-other",
              state: :bench,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            }
          ]
        },
        sport_id: "basketball"
      }

      event_payload = %{
        "team-type" => "away",
        "playing-player-id" => "some-id",
        "bench-player-id" => "some-other"
      }

      event = SubstitutePlayerDefinition.create(game_state.id, 10, 1, event_payload)

      new_game_state = SubstitutePlayerDefinition.handle(game_state, event)

      assert new_game_state.away_team.players == [
               %PlayerState{
                 id: "some-id",
                 state: :bench,
                 stats_values: %{"game_played" => 0, "game_started" => 0}
               },
               %PlayerState{
                 id: "some-other",
                 state: :playing,
                 stats_values: %{"game_played" => 1, "game_started" => 0}
               }
             ]
    end

    test "returns game state with check game_played player stat" do
      game_state = %GameState{
        away_team: %TeamState{
          players: [
            %PlayerState{
              id: "some-id",
              state: :playing,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            },
            %PlayerState{
              id: "some-other",
              state: :bench,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            }
          ]
        },
        sport_id: "basketball"
      }

      event_payload = %{
        "team-type" => "away",
        "playing-player-id" => "some-id",
        "bench-player-id" => "some-other"
      }

      event = SubstitutePlayerDefinition.create(game_state.id, 10, 1, event_payload)

      new_game_state = SubstitutePlayerDefinition.handle(game_state, event)

      assert new_game_state.away_team.players == [
               %PlayerState{
                 id: "some-id",
                 state: :bench,
                 stats_values: %{"game_played" => 0, "game_started" => 0}
               },
               %PlayerState{
                 id: "some-other",
                 state: :playing,
                 stats_values: %{
                   "game_played" => 1,
                   "game_started" => 0
                 }
               }
             ]
    end

    test "returns game state with updated player state when only bench player id is provided" do
      game_state = %GameState{
        away_team: %TeamState{
          players: [
            %PlayerState{
              id: "some-id",
              state: :playing,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            },
            %PlayerState{
              id: "some-other",
              state: :bench,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            }
          ]
        },
        sport_id: "basketball"
      }

      event_payload = %{
        "team-type" => "away",
        "playing-player-id" => nil,
        "bench-player-id" => "some-other"
      }

      event = SubstitutePlayerDefinition.create(game_state.id, 10, 1, event_payload)

      new_game_state = SubstitutePlayerDefinition.handle(game_state, event)

      assert new_game_state.away_team.players == [
               %PlayerState{
                 id: "some-id",
                 state: :playing,
                 stats_values: %{"game_played" => 0, "game_started" => 0}
               },
               %PlayerState{
                 id: "some-other",
                 state: :playing,
                 stats_values: %{"game_played" => 1, "game_started" => 1}
               }
             ]
    end

    test "returns game state with checked game_played and game_started stats when only bench player id is provided" do
      game_state = %GameState{
        away_team: %TeamState{
          players: [
            %PlayerState{
              id: "some-id",
              state: :playing,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            },
            %PlayerState{
              id: "some-other",
              state: :bench,
              stats_values: %{
                "game_played" => 0,
                "game_started" => 0
              }
            }
          ]
        },
        sport_id: "basketball"
      }

      event_payload = %{
        "team-type" => "away",
        "playing-player-id" => nil,
        "bench-player-id" => "some-other"
      }

      event = SubstitutePlayerDefinition.create(game_state.id, 10, 1, event_payload)

      new_game_state = SubstitutePlayerDefinition.handle(game_state, event)

      assert new_game_state.away_team.players == [
               %PlayerState{
                 id: "some-id",
                 state: :playing,
                 stats_values: %{"game_played" => 0, "game_started" => 0}
               },
               %PlayerState{
                 id: "some-other",
                 state: :playing,
                 stats_values: %{
                   "game_played" => 1,
                   "game_started" => 1
                 }
               }
             ]
    end
  end
end
