defmodule GoChampsScoreboard.Events.Definitions.RegisterTeamWODefinitionTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.RegisterTeamWODefinition
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Models.StreamConfig

  import GoChampsScoreboard.GameStateFixtures

  describe "key/0" do
    test "returns the correct key" do
      assert RegisterTeamWODefinition.key() == "register-team-wo"
    end
  end

  describe "validate/2" do
    test "always returns {:ok} for now" do
      assert RegisterTeamWODefinition.validate(%GameState{}, %{}) == {:ok}
    end
  end

  describe "create/4" do
    test "creates an event with the correct key and payload" do
      event = RegisterTeamWODefinition.create("game-id", 10, 1, %{"team-type" => "home"})

      assert %Event{
               key: "register-team-wo",
               game_id: "game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1,
               payload: %{"team-type" => "home"}
             } = event
    end
  end

  describe "handle/2" do
    test "returns the same game state for now" do
      game_state = %GameState{}
      event = %Event{payload: %{}}
      assert RegisterTeamWODefinition.handle(game_state, event) == game_state
    end

    test "returns updated game state when game stats is for basketball" do
      current_game = basketball_game_state_fixture()
      event = RegisterTeamWODefinition.create("game-id", 10, 1, %{"team-type" => "home"})
      result = RegisterTeamWODefinition.handle(current_game, event)

      assert result.info.result_type == :home_team_walkover
    end
  end

  describe "stream_config/0" do
    test "returns a StreamConfig struct" do
      config = RegisterTeamWODefinition.stream_config()

      assert %StreamConfig{} = config
    end
  end
end
