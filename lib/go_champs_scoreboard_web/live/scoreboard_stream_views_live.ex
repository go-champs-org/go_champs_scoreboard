defmodule GoChampsScoreboardWeb.ScoreboardStreamViewsLive do
  use GoChampsScoreboardWeb, :live_view
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.EventLogCache
  alias GoChampsScoreboard.Games.Messages.PubSub
  require Logger

  def mount(%{"game_id" => game_id}, %{"api_token" => api_token} = _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(game_id)
    end

    {:ok,
     socket
     |> assign(:api_token, api_token)
     |> assign_async(:game_state, fn ->
       {:ok, %{game_state: Games.find_or_bootstrap(game_id, api_token)}}
     end)
     |> assign_async(:recent_events, fn ->
       case EventLogCache.get(game_id) do
         {:ok, recent_events} -> {:ok, %{recent_events: recent_events}}
         _ -> {:ok, %{recent_events: []}}
       end
     end)}
  end

  def handle_info(msg, socket) do
    case msg do
      {:game_reacted_to_event, %{game_state: game_state}} ->
        updated_socket =
          socket
          |> assign(:game_state, %{socket.assigns.game_state | result: game_state})

        {:noreply, updated_socket}

      {:game_event_logs_updated, %{game_id: _game_id, recent_events: recent_events}} ->
        updated_socket =
          socket
          |> assign(:recent_events, %{result: recent_events})

        {:noreply, updated_socket}

      _ ->
        {:noreply, socket}
    end
  end
end
