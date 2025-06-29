defmodule GoChampsScoreboard.Infrastructure.RabbitMQ do
  use GenServer
  require Logger

  @exchange "game-events"
  @dead_letter_exchange "dead-letter-exchange"
  @retry_exchange "retry-exchange"

  # Main queues for game events
  @queue_game_events "game-events"
  @queue_live_mode "game-events-live-mode"
  @queue_stats "game-events-stats"
  @queue_dead_letter "dead-letter"

  # Retry queues for live-mode (no delays, handled by consumer)
  @retry_queues [
    "game-events-live-mode-retry-1",
    "game-events-live-mode-retry-2",
    "game-events-live-mode-retry-3",
    "game-events-live-mode-retry-4",
    "game-events-live-mode-retry-5"
  ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    case AMQP.Connection.open(
           Application.get_env(:go_champs_scoreboard, GoChampsScoreboard.Infrastructure.RabbitMQ)
         ) do
      {:ok, conn} ->
        case AMQP.Channel.open(conn) do
          {:ok, chan} ->
            Logger.info("Connected to RabbitMQ")

            setup(chan)
            setup_retry_queues(chan)

            {:ok, %{channel: chan}}

          {:error, reason} ->
            Logger.error("Failed to open channel: #{inspect(reason)}")
            {:stop, reason}
        end

      {:error, reason} ->
        Logger.error("Failed to open connection: #{inspect(reason)}")
        {:ok, reason}
    end
  end

  def publish(payload) do
    GenServer.call(__MODULE__, {:publish, payload})
  end

  def handle_call(
        {:publish, %{message: message, routing_key: routing_key}},
        _from,
        %{channel: chan} = state
      ) do
    Logger.info("Publishing message to RabbitMQ",
      message: message,
      exchange: @exchange,
      routing_key: routing_key
    )

    AMQP.Basic.publish(chan, @exchange, routing_key, message)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.warning("Unhandled call: #{inspect(msg)}")
    {:reply, :ok, state}
  end

  defp setup(chan) do
    # Declare exchanges
    AMQP.Exchange.declare(chan, @exchange, :topic)
    AMQP.Exchange.declare(chan, @dead_letter_exchange, :topic)

    # Declare queues with dead-lettering
    AMQP.Queue.declare(chan, @queue_dead_letter, durable: true)

    AMQP.Queue.declare(chan, @queue_game_events, durable: true)

    # Live mode queue with retry mechanism
    AMQP.Queue.declare(chan, @queue_live_mode,
      durable: true,
      arguments: [
        {"x-dead-letter-exchange", :longstr, @dead_letter_exchange}
      ]
    )

    AMQP.Queue.declare(chan, @queue_stats, durable: true)

    # Bind queues to exchanges with routing keys
    AMQP.Queue.bind(chan, @queue_game_events, @exchange, routing_key: "game-events.*")
    AMQP.Queue.bind(chan, @queue_live_mode, @exchange, routing_key: "game-events.live-mode")
    AMQP.Queue.bind(chan, @queue_stats, @exchange, routing_key: "game-events.player-stats")
    AMQP.Queue.bind(chan, @queue_stats, @exchange, routing_key: "game-events.team-stats")

    # Bind dead letter queue
    AMQP.Queue.bind(chan, @queue_dead_letter, @dead_letter_exchange, routing_key: "#")

    Logger.info("RabbitMQ setup completed")
  end

  defp setup_retry_queues(chan) do
    # Declare retry exchange
    AMQP.Exchange.declare(chan, @retry_exchange, :direct, durable: true)

    # Setup each retry queue
    Enum.each(@retry_queues, fn retry_queue ->
      AMQP.Queue.declare(
        chan,
        retry_queue,
        durable: true,
        arguments: [
          # When message expires, send it back to main queue
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, @queue_live_mode}
        ]
      )

      # Bind retry queue to retry exchange
      AMQP.Queue.bind(chan, retry_queue, @retry_exchange, routing_key: retry_queue)
    end)

    Logger.info("RabbitMQ retry queues setup completed")
  end
end
