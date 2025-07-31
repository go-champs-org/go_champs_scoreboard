defmodule GoChampsScoreboardWeb.ScoreboardStreamViewsLive do
  use GoChampsScoreboardWeb, :live_view
  alias GoChampsScoreboard.Games.Games
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
     end)}
  end

  @spec handle_info({:game_reacted_to_event, any()}, any()) :: {:noreply, any()}
  def handle_info({:game_reacted_to_event, %{game_state: game_state}}, socket) do
    updated_socket =
      socket
      |> assign(:game_state, %{socket.assigns.game_state | result: game_state})

    {:noreply, updated_socket}
  end

  def handle_info({:game_last_snapshot_updated, _payload}, socket) do
    {:noreply, socket}
  end
end
