defmodule GoChampsScoreboard.Games.GameProcess do
  use GenServer

  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.GameStateCache
  alias GoChampsScoreboard.Games.Messages.PubSub
  alias GoChampsScoreboard.Games.Models.GameState

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  @impl true
  def init(game_id) do
    case GameStateCache.get(game_id) do
      {:ok, nil} ->
        {:stop, :game_not_found}

      {:ok, game_state} ->
        {:ok, %{game_id: game_id, game_state: game_state}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @spec react_to_event(String.t(), Event.t()) :: GameState.t()
  def react_to_event(game_id, event) do
    GenServer.call(via_tuple(game_id), {:react_to_event, event})
  end

  @spec get_state(String.t()) :: GameState.t()
  def get_state(game_id) do
    GenServer.call(via_tuple(game_id), :get_state)
  end

  @impl true
  def handle_call({:react_to_event, event}, from, state) do
    new_game_state = Handler.handle(state.game_state, event)
    PubSub.broadcast_game_reacted_to_event(event, new_game_state)
    GenServer.reply(from, new_game_state)
    GameStateCache.update(new_game_state)
    {:noreply, %{state | game_state: new_game_state}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state.game_state, state}
  end

  defp via_tuple(game_id) do
    {:via, Registry, {GoChampsScoreboard.Games.GameProcessRegistry, game_id}}
  end
end
