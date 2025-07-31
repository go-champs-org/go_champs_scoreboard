defmodule GoChampsScoreboard.Infrastructure.GameEventLogsListener do
  alias GoChampsScoreboard.Events.Definitions.LoadFromLastEventLogDefinition
  alias GoChampsScoreboard.Games.Messages.PubSub
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Events.ValidatorCreator
  use GenServer

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def init(game_id) do
    PubSub.subscribe(game_id)

    {:ok, %{game_id: game_id}}
  end

  def handle_info(
        {:game_last_snapshot_updated, %{game_id: game_id} = _payload},
        state
      ) do
    {:ok, event} =
      LoadFromLastEventLogDefinition.key()
      |> ValidatorCreator.validate_and_create(game_id)

    event
    |> Games.react_to_event(game_id)

    {:noreply, state}
  end

  def handle_info({:game_reacted_to_event, %{event: _event, game_state: _game_state}}, state) do
    # GameEventLogsListener doesn't need to handle game reaction events
    # This listener only responds to snapshot updates
    {:noreply, state}
  end

  def handle_call(:process_pending_messages, _from, state) do
    {:messages, pending_messages} = Process.info(self(), :messages)

    Enum.each(pending_messages, fn message ->
      handle_info(message, state)
    end)

    {:reply, :ok, state}
  end

  defp via_tuple(game_id) do
    {:via, Registry, {GoChampsScoreboard.Infrastructure.GameEventLogsListenerRegistry, game_id}}
  end
end
