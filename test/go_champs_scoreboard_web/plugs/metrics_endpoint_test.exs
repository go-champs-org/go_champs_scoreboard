defmodule GoChampsScoreboardWeb.Plugs.MetricsEndpointTest do
  # Changes the :metrics_token application env, so it cannot run concurrently.
  use GoChampsScoreboardWeb.ConnCase, async: false

  alias GoChampsScoreboard.Telemetry

  setup do
    previous = Application.get_env(:go_champs_scoreboard, :metrics_token)
    on_exit(fn -> Application.put_env(:go_champs_scoreboard, :metrics_token, previous) end)
  end

  test "answers 404 when no token is configured", %{conn: conn} do
    Application.put_env(:go_champs_scoreboard, :metrics_token, nil)

    assert conn |> get("/metrics") |> response(404)
  end

  test "answers 401 without a valid bearer token", %{conn: conn} do
    Application.put_env(:go_champs_scoreboard, :metrics_token, "secret")

    assert conn |> get("/metrics") |> response(401)

    assert conn
           |> put_req_header("authorization", "Bearer wrong")
           |> get("/metrics")
           |> response(401)
  end

  test "exports the game pipeline metrics with a valid bearer token", %{conn: conn} do
    Application.put_env(:go_champs_scoreboard, :metrics_token, "secret")

    Telemetry.game_event_processed("metrics-endpoint-test")
    Telemetry.span(:persist, fn -> {:ok, :persisted} end)
    Telemetry.span(:snapshot_rebuild, fn -> :ok end)
    Telemetry.span(:rabbitmq_publish, fn -> :ok end)
    Telemetry.rabbitmq_unroutable()
    # The same function PromEx polls every few seconds, so the series does not
    # depend on waiting for a poll.
    Telemetry.live_games()

    body =
      conn
      |> put_req_header("authorization", "Bearer secret")
      |> get("/metrics")
      |> response(200)

    assert body =~ ~s(go_champs_scoreboard_prom_ex_game_events_total{key="metrics-endpoint-test"})
    assert body =~ "go_champs_scoreboard_prom_ex_game_persist_duration_milliseconds_bucket"

    assert body =~
             "go_champs_scoreboard_prom_ex_game_snapshot_rebuild_duration_milliseconds_bucket"

    assert body =~ "go_champs_scoreboard_prom_ex_rabbitmq_publish_duration_milliseconds_bucket"
    assert body =~ "go_champs_scoreboard_prom_ex_rabbitmq_unroutable_total"
    assert body =~ "go_champs_scoreboard_prom_ex_game_live_games"
    assert body =~ "go_champs_scoreboard_prom_ex_beam_"
    # Only exported when PromEx is up before the endpoint initializes.
    assert body =~ "go_champs_scoreboard_prom_ex_phoenix_endpoint_url_info"
  end
end
