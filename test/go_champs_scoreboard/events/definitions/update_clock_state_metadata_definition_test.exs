defmodule GoChampsScoreboard.Events.Definitions.UpdateClockStateMetadataDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.UpdateClockStateMetadataDefinition
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.GameClockState

  describe "validate/2" do
    test "returns :ok" do
      game_state = %GameState{clock_state: GameClockState.new()}
      payload = %{"initial_period_time" => 600}

      assert {:ok} = UpdateClockStateMetadataDefinition.validate(game_state, payload)
    end
  end

  describe "create/4" do
    test "returns event" do
      assert %Event{
               key: "update-clock-state-metadata",
               game_id: "some-game-id",
               clock_state_time_at: 10,
               clock_state_period_at: 1
             } =
               UpdateClockStateMetadataDefinition.create("some-game-id", 10, 1, %{
                 "initial_period_time" => 600
               })
    end
  end

  describe "handle/2" do
    @initial_state %GameState{
      clock_state: GameClockState.new(480, 300, 240, 2, :paused, nil, nil),
      sport_id: "sport_type"
    }

    test "updates initial_period_time" do
      payload = %{"initial_period_time" => 720}
      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)

      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.initial_period_time == 720
      assert result.clock_state.initial_extra_period_time == 300
      assert result.clock_state.time == 240
      assert result.clock_state.period == 2
      assert result.clock_state.state == :paused
      assert result != @initial_state
    end

    test "updates initial_extra_period_time" do
      payload = %{"initial_extra_period_time" => 360}
      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)

      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.initial_period_time == 480
      assert result.clock_state.initial_extra_period_time == 360
      assert result.clock_state.time == 240
      assert result.clock_state.period == 2
      assert result.clock_state.state == :paused
      assert result != @initial_state
    end

    test "updates started_at with valid datetime string" do
      started_at = "2023-12-01T10:00:00Z"
      payload = %{"started_at" => started_at}
      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)

      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.started_at != nil
      assert DateTime.to_iso8601(result.clock_state.started_at) == "2023-12-01T10:00:00Z"
      assert result != @initial_state
    end

    test "updates finished_at with valid datetime string" do
      finished_at = "2023-12-01T12:00:00Z"
      payload = %{"finished_at" => finished_at}
      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)

      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.finished_at != nil
      assert DateTime.to_iso8601(result.clock_state.finished_at) == "2023-12-01T12:00:00Z"
      assert result != @initial_state
    end

    test "updates multiple fields at once" do
      started_at = "2023-12-01T10:00:00Z"
      finished_at = "2023-12-01T12:00:00Z"

      payload = %{
        "initial_period_time" => 900,
        "initial_extra_period_time" => 450,
        "started_at" => started_at,
        "finished_at" => finished_at
      }

      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.initial_period_time == 900
      assert result.clock_state.initial_extra_period_time == 450
      assert DateTime.to_iso8601(result.clock_state.started_at) == "2023-12-01T10:00:00Z"
      assert DateTime.to_iso8601(result.clock_state.finished_at) == "2023-12-01T12:00:00Z"
      # Verify other fields are unchanged
      assert result.clock_state.time == 240
      assert result.clock_state.period == 2
      assert result.clock_state.state == :paused
      assert result != @initial_state
    end

    test "ignores nil values" do
      payload = %{
        "initial_period_time" => 720,
        "initial_extra_period_time" => nil,
        "started_at" => nil,
        "finished_at" => nil
      }

      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.initial_period_time == 720
      # unchanged
      assert result.clock_state.initial_extra_period_time == 300
      # unchanged
      assert result.clock_state.started_at == nil
      # unchanged
      assert result.clock_state.finished_at == nil
      assert result != @initial_state
    end

    test "ignores missing fields" do
      payload = %{"initial_period_time" => 720}
      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)

      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.initial_period_time == 720
      # unchanged
      assert result.clock_state.initial_extra_period_time == 300
      # unchanged
      assert result.clock_state.started_at == nil
      # unchanged
      assert result.clock_state.finished_at == nil
      assert result != @initial_state
    end

    test "handles invalid datetime strings gracefully" do
      payload = %{
        "started_at" => "invalid-datetime",
        "finished_at" => "also-invalid",
        # Add a valid change to ensure state differs
        "initial_period_time" => 720
      }

      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)
      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      assert result.clock_state.started_at == nil
      assert result.clock_state.finished_at == nil
      # This should have changed
      assert result.clock_state.initial_period_time == 720
      assert result != @initial_state
    end

    test "preserves immutability" do
      payload = %{"initial_period_time" => 720}
      event = UpdateClockStateMetadataDefinition.create("game-id", 10, 1, payload)

      original_clock_state = @initial_state.clock_state
      result = UpdateClockStateMetadataDefinition.handle(@initial_state, event)

      # Verify original state is unchanged
      assert @initial_state.clock_state.initial_period_time == 480
      assert original_clock_state.initial_period_time == 480

      # Verify new state has the update
      assert result.clock_state.initial_period_time == 720
      assert result != @initial_state
    end
  end
end
