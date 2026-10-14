defmodule GoChampsScoreboard.PromEx.GamePlugin do
  @moduledoc """
  PromEx plugin exporting the live game pipeline, emitted by
  `GoChampsScoreboard.Telemetry`:

    * `..._game_live_games` - games with a running ticker.
    * `..._game_events_total` - processed game events by `key` (ticks excluded).
    * `..._game_persist_duration_milliseconds` - persisting an event and its
      snapshot, tagged by `result`.
    * `..._game_snapshot_rebuild_duration_milliseconds` - full snapshot rebuild,
      tagged by `result`.
    * `..._rabbitmq_publish_duration_milliseconds` - publishing to RabbitMQ as
      the caller sees it (includes waiting for the publisher process), tagged by
      `result`.
    * `..._rabbitmq_unroutable_total` - messages the broker returned as
      unroutable.
  """

  use PromEx.Plugin

  @persist_buckets [5, 10, 25, 50, 100, 250, 500, 1_000, 2_500]
  @rebuild_buckets [50, 100, 250, 500, 1_000, 5_000, 15_000, 60_000]
  @publish_buckets [1, 5, 10, 25, 50, 100, 250, 1_000, 5_000]

  @poll_rate 5_000

  @impl true
  def polling_metrics(opts) do
    prefix = metric_prefix(opts, :game)

    Polling.build(
      :go_champs_scoreboard_game_polling_metrics,
      @poll_rate,
      {GoChampsScoreboard.Telemetry, :live_games, []},
      [
        last_value(
          prefix ++ [:live_games],
          event_name: [:go_champs_scoreboard, :game, :live],
          measurement: :count,
          description: "The number of games with a running ticker."
        )
      ]
    )
  end

  @impl true
  def event_metrics(opts) do
    game_prefix = metric_prefix(opts, :game)
    rabbitmq_prefix = metric_prefix(opts, :rabbitmq)

    [
      Event.build(:go_champs_scoreboard_game_event_metrics, [
        counter(
          game_prefix ++ [:events, :total],
          event_name: [:go_champs_scoreboard, :game_event, :processed],
          description: "The number of processed game events, by event key.",
          tags: [:key]
        ),
        distribution(
          game_prefix ++ [:persist, :duration, :milliseconds],
          event_name: [:go_champs_scoreboard, :persist, :duration],
          measurement: :duration,
          description: "The amount of time persisting a game event and its snapshot takes.",
          reporter_options: [buckets: @persist_buckets],
          tags: [:result],
          unit: {:native, :millisecond}
        ),
        distribution(
          game_prefix ++ [:snapshot_rebuild, :duration, :milliseconds],
          event_name: [:go_champs_scoreboard, :snapshot_rebuild, :duration],
          measurement: :duration,
          description: "The amount of time rebuilding all snapshots of a game takes.",
          reporter_options: [buckets: @rebuild_buckets],
          tags: [:result],
          unit: {:native, :millisecond}
        )
      ]),
      Event.build(:go_champs_scoreboard_rabbitmq_event_metrics, [
        distribution(
          rabbitmq_prefix ++ [:publish, :duration, :milliseconds],
          event_name: [:go_champs_scoreboard, :rabbitmq_publish, :duration],
          measurement: :duration,
          description: "The amount of time publishing a message to RabbitMQ takes.",
          reporter_options: [buckets: @publish_buckets],
          tags: [:result],
          unit: {:native, :millisecond}
        ),
        counter(
          rabbitmq_prefix ++ [:unroutable, :total],
          event_name: [:go_champs_scoreboard, :rabbitmq, :unroutable],
          description: "The number of published messages RabbitMQ could not route."
        )
      ])
    ]
  end

  defp metric_prefix(opts, group) do
    opts
    |> Keyword.fetch!(:otp_app)
    |> PromEx.metric_prefix(group)
  end
end
