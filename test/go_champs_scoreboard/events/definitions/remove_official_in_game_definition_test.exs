defmodule GoChampsScoreboard.Events.Definitions.RemoveOfficialInGameDefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.RemoveOfficialInGameDefinition
  alias GoChampsScoreboard.Events.Models.Event

  alias GoChampsScoreboard.Games.Models.{
    GameState,
    TeamState,
    GameClockState,
    LiveState,
    OfficialState
  }

  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.Models.StreamConfig

  setup do
    game_state =
      GameState.new(
        "game-123",
        %TeamState{},
        %TeamState{},
        %GameClockState{},
        %LiveState{}
      )

    {:ok, game_state: game_state}
  end

  describe "key/0" do
    test "returns correct event key" do
      assert RemoveOfficialInGameDefinition.key() == "remove-official-in-game"
    end
  end

  describe "validate/2" do
    test "validates any payload (currently returns ok for any input)" do
      assert RemoveOfficialInGameDefinition.validate(nil, %{}) == {:ok}

      assert RemoveOfficialInGameDefinition.validate(nil, %{"id" => Ecto.UUID.generate()}) ==
               {:ok}

      assert RemoveOfficialInGameDefinition.validate(nil, "invalid") == {:ok}
    end
  end

  describe "create/4" do
    test "creates event with correct attributes" do
      payload = %{"id" => Ecto.UUID.generate()}

      event = RemoveOfficialInGameDefinition.create("game-123", 600, 1, payload)

      assert %Event{} = event
      assert event.key == "remove-official-in-game"
      assert event.game_id == "game-123"
      assert event.clock_state_time_at == 600
      assert event.clock_state_period_at == 1
      assert event.payload == payload
    end
  end

  describe "handle/2" do
    test "removes existing official by id", %{game_state: game_state} do
      # First add officials
      scorer = OfficialState.new(Ecto.UUID.generate(), "John Doe", :scorer, "SC001", "FIBA")

      timekeeper =
        OfficialState.new(Ecto.UUID.generate(), "Jane Smith", :timekeeper, "TK001", "FIBA")

      game_with_officials =
        game_state
        |> Games.add_official(scorer)
        |> Games.add_official(timekeeper)

      assert length(game_with_officials.officials) == 2

      # Remove the scorer by ID
      payload = %{"id" => scorer.id}
      event = Event.new("remove-official-in-game", "game-123", 600, 1, payload)
      updated_game = RemoveOfficialInGameDefinition.handle(game_with_officials, event)

      # Verify scorer was removed but timekeeper remains
      assert length(updated_game.officials) == 1
      assert not Enum.any?(updated_game.officials, fn o -> o.id == scorer.id end)
      assert Enum.any?(updated_game.officials, fn o -> o.id == timekeeper.id end)

      remaining_official = List.first(updated_game.officials)
      assert remaining_official.name == "Jane Smith"
      assert remaining_official.type == :timekeeper
    end

    test "handles removing non-existent official gracefully", %{game_state: game_state} do
      # Try to remove an official that doesn't exist
      non_existent_id = Ecto.UUID.generate()
      payload = %{"id" => non_existent_id}
      event = Event.new("remove-official-in-game", "game-123", 600, 1, payload)
      updated_game = RemoveOfficialInGameDefinition.handle(game_state, event)

      # Game state should remain unchanged
      assert updated_game.officials == game_state.officials
      assert length(updated_game.officials) == 0
    end

    test "removes specific official when multiple officials of same type exist", %{
      game_state: game_state
    } do
      # Add multiple officials of the same type (this scenario might not be common but tests specificity)
      scorer1 = OfficialState.new(Ecto.UUID.generate(), "John Scorer", :scorer, "SC001", "FIBA")
      scorer2 = OfficialState.new(Ecto.UUID.generate(), "Jane Scorer", :scorer, "SC002", "NBA")

      timekeeper =
        OfficialState.new(Ecto.UUID.generate(), "Bob Timekeeper", :timekeeper, "TK001", "FIBA")

      game_with_officials =
        game_state
        |> Games.add_official(scorer1)
        |> Games.add_official(scorer2)
        |> Games.add_official(timekeeper)

      assert length(game_with_officials.officials) == 3

      # Remove only the first scorer by ID
      payload = %{"id" => scorer1.id}
      event = Event.new("remove-official-in-game", "game-123", 600, 1, payload)
      updated_game = RemoveOfficialInGameDefinition.handle(game_with_officials, event)

      # Verify only the specific scorer was removed
      assert length(updated_game.officials) == 2
      assert not Enum.any?(updated_game.officials, fn o -> o.id == scorer1.id end)
      assert Enum.any?(updated_game.officials, fn o -> o.id == scorer2.id end)
      assert Enum.any?(updated_game.officials, fn o -> o.id == timekeeper.id end)
    end

    test "removes all officials when removing by their individual IDs", %{game_state: game_state} do
      # Add all types of officials
      officials = [
        OfficialState.new(Ecto.UUID.generate(), "Scorer", :scorer),
        OfficialState.new(Ecto.UUID.generate(), "Assistant Scorer", :assistant_scorer),
        OfficialState.new(Ecto.UUID.generate(), "Timekeeper", :timekeeper),
        OfficialState.new(Ecto.UUID.generate(), "Shot Clock Op", :shot_clock_operator),
        OfficialState.new(Ecto.UUID.generate(), "Crew Chief", :crew_chief),
        OfficialState.new(Ecto.UUID.generate(), "Umpire 1", :umpire_1),
        OfficialState.new(Ecto.UUID.generate(), "Umpire 2", :umpire_2)
      ]

      game_with_all_officials = %{game_state | officials: officials}
      assert length(game_with_all_officials.officials) == 7

      # Remove each official by their ID
      final_game =
        officials
        |> Enum.reduce(game_with_all_officials, fn official, acc_game ->
          payload = %{"id" => official.id}
          event = Event.new("remove-official-in-game", "game-123", 600, 1, payload)
          RemoveOfficialInGameDefinition.handle(acc_game, event)
        end)

      # All officials should be removed
      assert length(final_game.officials) == 0
    end

    test "preserves other game state properties", %{game_state: game_state} do
      # Add an official first
      scorer = OfficialState.new(Ecto.UUID.generate(), "Test Official", :scorer)
      game_with_official = Games.add_official(game_state, scorer)

      payload = %{"id" => scorer.id}
      event = Event.new("remove-official-in-game", "game-123", 600, 1, payload)

      updated_game = RemoveOfficialInGameDefinition.handle(game_with_official, event)

      # All other properties should remain unchanged
      assert updated_game.id == game_state.id
      assert updated_game.away_team == game_state.away_team
      assert updated_game.home_team == game_state.home_team
      assert updated_game.clock_state == game_state.clock_state
      assert updated_game.sport_id == game_state.sport_id
      assert updated_game.live_state == game_state.live_state
      assert updated_game.view_settings_state == game_state.view_settings_state
    end

    test "handles multiple officials of different types correctly", %{game_state: game_state} do
      # Add multiple officials
      scorer = OfficialState.new(Ecto.UUID.generate(), "John Scorer", :scorer)
      crew_chief = OfficialState.new(Ecto.UUID.generate(), "Mike Chief", :crew_chief)
      umpire1 = OfficialState.new(Ecto.UUID.generate(), "Bob Umpire", :umpire_1)

      game_with_officials =
        game_state
        |> Games.add_official(scorer)
        |> Games.add_official(crew_chief)
        |> Games.add_official(umpire1)

      assert length(game_with_officials.officials) == 3

      # Remove crew chief by ID
      payload = %{"id" => crew_chief.id}
      event = Event.new("remove-official-in-game", "game-123", 600, 1, payload)
      updated_game = RemoveOfficialInGameDefinition.handle(game_with_officials, event)

      # Verify only crew chief was removed
      assert length(updated_game.officials) == 2
      assert Enum.any?(updated_game.officials, fn o -> o.id == scorer.id end)
      assert not Enum.any?(updated_game.officials, fn o -> o.id == crew_chief.id end)
      assert Enum.any?(updated_game.officials, fn o -> o.id == umpire1.id end)
    end
  end

  describe "stream_config/0" do
    test "returns a StreamConfig struct" do
      config = RemoveOfficialInGameDefinition.stream_config()
      assert %StreamConfig{} = config
    end
  end
end
