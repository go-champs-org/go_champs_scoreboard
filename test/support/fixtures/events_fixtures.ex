defmodule GoChampsScoreboard.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoChampsScoreboard.Events` context.
  """

  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Games.EventLogs
  import GoChampsScoreboard.GameStateFixtures

  @doc """
  Generate a event_log with a snapshot.
  """
  def event_log_with_snapshot_fixture(_attrs \\ %{}) do
    game_state = game_state_fixture()

    start_live_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        10,
        1,
        %{}
      )

    {:ok, event_log} = EventLogs.persist(start_live_event, game_state)

    event_log
  end

  @doc """
  Generate a event_log with a snapshot in the middle of the game.
  """
  def event_log_with_snapshot_in_middle_of_game_fixture(_attrs \\ %{}) do
    game_state = game_state_with_players_fixture()

    start_live_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        10,
        1,
        %{}
      )

    # Event field goal made
    payload = %{
      "operation" => "increment",
      "team-type" => "home",
      "player-id" => "123",
      "stat-id" => "field_goals_made"
    }

    update_player_stat_event =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        8,
        1,
        payload
      )

    game_state_for_update_player_stat_event = Handler.handle(game_state, update_player_stat_event)

    {:ok, _event_log} = EventLogs.persist(start_live_event, game_state)

    {:ok, event_log} =
      EventLogs.persist(update_player_stat_event, game_state_for_update_player_stat_event)

    event_log
  end

  def game_full_event_log_fixture() do
    home_players = [
      %PlayerState{
        id: "123",
        stats_values: %{
          "field_goals_made" => 0,
          "free_throws_made" => 0,
          "three_point_field_goals_made" => 0
        },
        name: "Home Player 12",
        number: 12,
        state: :available
      }
    ]

    away_players = [
      %PlayerState{
        id: "456",
        stats_values: %{
          "field_goals_made" => 0,
          "free_throws_made" => 0,
          "three_point_field_goals_made" => 0
        },
        name: "Away Player 22",
        number: 22,
        state: :available
      }
    ]

    game_state =
      game_state_with_players_fixture(home_players: home_players, away_players: away_players)

    start_live_event =
      GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition.create(
        game_state.id,
        10,
        1,
        %{}
      )

    # Event free throw made
    payload_1 = %{
      "operation" => "increment",
      "team-type" => "home",
      "player-id" => "123",
      "stat-id" => "free_throws_made"
    }

    # Event field goal made
    payload_2 = %{
      "operation" => "increment",
      "team-type" => "home",
      "player-id" => "123",
      "stat-id" => "field_goals_made"
    }

    # Event three point field goal made
    payload_3 = %{
      "operation" => "increment",
      "team-type" => "home",
      "player-id" => "123",
      "stat-id" => "three_point_field_goals_made"
    }

    update_player_stat_event_1 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        9,
        1,
        payload_1
      )

    update_player_stat_event_2 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        8,
        1,
        payload_2
      )

    update_player_stat_event_3 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        7,
        1,
        payload_3
      )

    update_player_stat_event_4 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        6,
        2,
        payload_3
      )

    update_player_stat_event_5 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        5,
        2,
        payload_2
      )

    update_player_stat_event_6 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        4,
        2,
        payload_1
      )

    update_player_stat_event_7 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        3,
        3,
        payload_1
      )

    update_player_stat_event_8 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        2,
        3,
        payload_2
      )

    update_player_stat_event_9 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        1,
        3,
        payload_3
      )

    update_player_stat_event_10 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        9,
        4,
        payload_3
      )

    update_player_stat_event_11 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        8,
        4,
        payload_2
      )

    update_player_stat_event_12 =
      GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition.create(
        game_state.id,
        7,
        4,
        payload_1
      )

    end_live_event =
      GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition.create(
        game_state.id,
        0,
        4,
        %{}
      )

    all_events = [
      start_live_event,
      update_player_stat_event_1,
      update_player_stat_event_2,
      update_player_stat_event_3,
      update_player_stat_event_4,
      update_player_stat_event_5,
      update_player_stat_event_6,
      update_player_stat_event_7,
      update_player_stat_event_8,
      update_player_stat_event_9,
      update_player_stat_event_10,
      update_player_stat_event_11,
      update_player_stat_event_12,
      end_live_event
    ]

    Enum.reduce(all_events, game_state, fn event, acc ->
      reacted_game = Handler.handle(game_state, event)

      {:ok, _event_log} = EventLogs.persist(event, acc)

      reacted_game
    end)
  end
end
