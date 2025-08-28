defmodule GoChampsScoreboard.Events.Definitions.RegistryTest do
  use ExUnit.Case

  alias GoChampsScoreboard.Events.Definitions.Registry
  alias GoChampsScoreboard.Events.Definitions.StartGameDefinition
  alias GoChampsScoreboard.Events.Definitions.EndGameDefinition
  alias GoChampsScoreboard.Events.Definitions.EndPeriodDefinition
  alias GoChampsScoreboard.Events.Definitions.LoadFromLastEventLogDefinition
  alias GoChampsScoreboard.Events.Definitions.ProtestGameDefinition

  describe "get_definition/1" do
    test "returns StartGameDefinition for start-game key" do
      assert {:ok, StartGameDefinition} = Registry.get_definition("start-game")
    end

    test "returns EndGameDefinition for end-game key" do
      assert {:ok, EndGameDefinition} = Registry.get_definition("end-game")
    end

    test "returns EndPeriodDefinition for end-period key" do
      assert {:ok, EndPeriodDefinition} = Registry.get_definition("end-period")
    end

    test "returns LoadFromLastEventLogDefinition for load-from-last-event-log key" do
      assert {:ok, LoadFromLastEventLogDefinition} =
               Registry.get_definition("load-from-last-event-log")
    end

    test "returns ProtestGameDefinition for protest-game key" do
      assert {:ok, ProtestGameDefinition} = Registry.get_definition("protest-game")
    end

    test "returns error for unknown key" do
      assert {:error, :not_registered} = Registry.get_definition("unknown-event")
    end
  end

  describe "registry contains new events" do
    test "start-game event is registered" do
      assert {:ok, definition} = Registry.get_definition("start-game")
      assert definition.key() == "start-game"
    end

    test "end-game event is registered" do
      assert {:ok, definition} = Registry.get_definition("end-game")
      assert definition.key() == "end-game"
    end

    test "load-from-last-event-log event is registered" do
      assert {:ok, definition} = Registry.get_definition("load-from-last-event-log")
      assert definition.key() == "load-from-last-event-log"
    end

    test "protest-game event is registered" do
      assert {:ok, definition} = Registry.get_definition("protest-game")
      assert definition.key() == "protest-game"
    end
  end
end
