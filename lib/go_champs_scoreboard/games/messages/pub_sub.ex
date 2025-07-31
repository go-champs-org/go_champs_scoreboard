defmodule GoChampsScoreboard.Games.Messages.PubSub do
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Events.Models.Event

  @spec subscribe(String.t()) :: :ok | {:error, {:already_registered, pid()}}
  def subscribe(game_id, pub_sub \\ GoChampsScoreboard.PubSub) do
    Phoenix.PubSub.subscribe(pub_sub, topic(game_id))
  end

  @spec topic(String.t()) :: String.t()
  def topic(game_id) do
    "game-" <> game_id
  end

  @spec broadcast_game_reacted_to_event(Event.t(), GameState.t()) :: :ok
  def broadcast_game_reacted_to_event(event, game_state, pub_sub \\ GoChampsScoreboard.PubSub) do
    Phoenix.PubSub.broadcast(
      pub_sub,
      topic(game_state.id),
      {:game_reacted_to_event, %{event: event, game_state: game_state}}
    )
  end

  @spec boardcast_game_last_snapshot_updated(String.t()) :: :ok
  def boardcast_game_last_snapshot_updated(game_id, pub_sub \\ GoChampsScoreboard.PubSub) do
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

  @callback subscribe(String.t(), module()) :: :ok | {:error, {:already_registered, pid()}}
  @callback topic(String.t()) :: String.t()
  @callback broadcast_game_reacted_to_event(Event.t(), GameState.t(), module()) :: :ok
  @callback boardcast_game_last_snapshot_updated(String.t(), module()) :: :ok
end
