defmodule GoChampsScoreboard.Games.Messages.PubSub do
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.EventLog

  @spec subscribe(String.t()) :: :ok | {:error, {:already_registered, pid()}}
  def subscribe(game_id, pub_sub \\ GoChampsScoreboard.PubSub) do
    Phoenix.PubSub.subscribe(pub_sub, topic(game_id))
  end

  @spec topic(String.t()) :: String.t()
  def topic(game_id) do
    "game-" <> game_id
  end

  @spec broadcast_game_event_logs_updated(String.t(), [EventLog.t()]) :: :ok
  def broadcast_game_event_logs_updated(
        game_id,
        recent_events,
        pub_sub \\ GoChampsScoreboard.PubSub
      ) do
    Phoenix.PubSub.broadcast(
      pub_sub,
      topic(game_id),
      {:game_event_logs_updated, %{game_id: game_id, recent_events: recent_events}}
    )
  end

  @spec broadcast_game_reacted_to_event(Event.t(), GameState.t()) :: :ok
  def broadcast_game_reacted_to_event(event, game_state, pub_sub \\ GoChampsScoreboard.PubSub) do
    Phoenix.PubSub.broadcast(
      pub_sub,
      topic(game_state.id),
      {:game_reacted_to_event, %{event: event, game_state: game_state}}
    )
  end

  @spec broadcast_game_last_snapshot_updated(String.t()) :: :ok
  def broadcast_game_last_snapshot_updated(game_id, pub_sub \\ GoChampsScoreboard.PubSub) do
    Phoenix.PubSub.broadcast(
      pub_sub,
      topic(game_id),
      {:game_last_snapshot_updated, %{game_id: game_id}}
    )
  end
end

defmodule GoChampsScoreboard.Games.Messages.PubSubBehavior do
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.EventLog

  @callback subscribe(String.t(), module()) :: :ok | {:error, {:already_registered, pid()}}
  @callback topic(String.t()) :: String.t()
  @callback broadcast_game_event_logs_updated(String.t(), [EventLog.t()], module()) :: :ok
  @callback broadcast_game_reacted_to_event(Event.t(), GameState.t(), module()) :: :ok
  @callback broadcast_game_last_snapshot_updated(String.t(), module()) :: :ok
end
