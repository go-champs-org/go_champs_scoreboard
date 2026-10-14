defmodule GoChampsScoreboard.TelemetryTest do
  use ExUnit.Case, async: true

  alias GoChampsScoreboard.Telemetry

  setup do
    ref = make_ref()
    test_pid = self()

    :telemetry.attach_many(
      "telemetry-test-#{inspect(ref)}",
      [
        [:go_champs_scoreboard, :sample, :duration],
        [:go_champs_scoreboard, :game_event, :processed],
        [:go_champs_scoreboard, :rabbitmq, :unroutable],
        [:go_champs_scoreboard, :game, :live]
      ],
      fn event, measurements, metadata, _ ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end,
      nil
    )

    on_exit(fn -> :telemetry.detach("telemetry-test-#{inspect(ref)}") end)
  end

  describe "span/2" do
    test "returns the result and tags an ok result" do
      assert {:ok, 1} = Telemetry.span(:sample, fn -> {:ok, 1} end)

      assert_receive {:telemetry, [:go_champs_scoreboard, :sample, :duration],
                      %{duration: duration}, %{result: :ok}}

      assert is_integer(duration)
    end

    test "tags :error and {:error, _} results as error" do
      assert :error = Telemetry.span(:sample, fn -> :error end)
      assert_receive {:telemetry, _, _, %{result: :error}}

      assert {:error, :boom} = Telemetry.span(:sample, fn -> {:error, :boom} end)
      assert_receive {:telemetry, _, _, %{result: :error}}
    end

    test "tags an exception and re-raises it" do
      assert_raise RuntimeError, "boom", fn ->
        Telemetry.span(:sample, fn -> raise "boom" end)
      end

      assert_receive {:telemetry, _, _, %{result: :exception}}
    end

    test "tags an exit and re-exits" do
      assert catch_exit(Telemetry.span(:sample, fn -> exit(:timeout) end)) == :timeout

      assert_receive {:telemetry, _, _, %{result: :exception}}
    end
  end

  test "game_event_processed/1 carries the event key" do
    Telemetry.game_event_processed("update-player-stat")

    assert_receive {:telemetry, [:go_champs_scoreboard, :game_event, :processed], %{count: 1},
                    %{key: "update-player-stat"}}
  end

  test "rabbitmq_unroutable/0 emits a count" do
    Telemetry.rabbitmq_unroutable()

    assert_receive {:telemetry, [:go_champs_scoreboard, :rabbitmq, :unroutable], %{count: 1}, _}
  end

  test "live_games/0 emits the number of running tickers" do
    Telemetry.live_games()

    assert_receive {:telemetry, [:go_champs_scoreboard, :game, :live], %{count: count}, _}
    assert is_integer(count)
  end
end
