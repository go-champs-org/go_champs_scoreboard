defmodule GoChampsScoreboard.Infrastructure.RabbitMQ do
  use GenServer
  require Logger

  @exchange "game-events"
  @dead_letter_exchange "dead-letter-exchange"
  @queue_game_events "game-events"
  @queue_live_mode "game-events-live-mode"
  @queue_stats "game-events-stats"
  @queue_dead_letter "dead-letter"

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

    AMQP.Queue.declare(chan, @queue_game_events,
      durable: true
      # arguments: [
      #   {"dead-letter-exchange", :longstr, @dead_letter_exchange},
      #   {"dead-letter-routing-key", :longstr, @queue_dead_letter},
      #   {"delivery-limit", :signedint, 5}
      # ]
    )

    AMQP.Queue.declare(chan, @queue_live_mode,
      durable: true
      # arguments: [
      #   {"dead-letter-exchange", :longstr, @dead_letter_exchange},
      #   {"dead-letter-routing-key", :longstr, @queue_dead_letter},
      #   {"delivery-limit", :signedint, 5}
      # ]
    )

    AMQP.Queue.declare(chan, @queue_stats,
      durable: true
      # arguments: [
      #   {"dead-letter-exchange", :longstr, @dead_letter_exchange},
      #   {"dead-letter-routing-key", :longstr, @queue_dead_letter},
      #   {"delivery-limit", :signedint, 5}
      # ]
    )

    # Bind queues to exchanges with routing keys
    AMQP.Queue.bind(chan, @queue_game_events, @exchange, routing_key: "game-events.*")
    AMQP.Queue.bind(chan, @queue_live_mode, @exchange, routing_key: "game-events.live-mode")
    AMQP.Queue.bind(chan, @queue_stats, @exchange, routing_key: "game-events.player-stats")
    AMQP.Queue.bind(chan, @queue_stats, @exchange, routing_key: "game-events.team-stats")

    Logger.info("RabbitMQ setup completed")
  end
end
