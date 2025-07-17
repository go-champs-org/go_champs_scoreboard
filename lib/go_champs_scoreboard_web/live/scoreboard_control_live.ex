defmodule GoChampsScoreboardWeb.ScoreboardControlLive do
  alias GoChampsScoreboard.Infrastructure.FeatureFlags
  alias GoChampsScoreboard.Events.ValidatorCreator
  alias GoChampsScoreboard.Games.Games
  alias GoChampsScoreboard.Games.Messages.PubSub
  alias GoChampsScoreboard.ApiClient
  use GoChampsScoreboardWeb, :live_view
  require Logger

  def mount(%{"game_id" => game_id}, %{"api_token" => api_token} = _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(game_id)
    end

    {:ok,
     socket
     |> assign(:api_token, api_token)
     |> assign(:feature_flags, FeatureFlags.all_flags())
     |> assign_async(:game_state, fn ->
       {:ok, %{game_state: Games.find_or_bootstrap(game_id, api_token)}}
     end)}
  end

  def handle_event("update-player-stat", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("update-player-stat", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-coach-stat", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("update-coach-stat", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-team-stat", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("update-team-stat", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-coach-in-team", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("update-coach-in-team", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-player-in-team", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("update-player-in-team", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-clock-state", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("update-clock-state", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("add-coach-to-team", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("add-coach-to-team", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("add-official-to-game", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("add-official-to-game", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("add-player-to-team", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("add-player-to-team", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("remove-coach-in-team", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("remove-coach-in-team", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("remove-official-in-game", params, socket) do
    game_id = socket.assigns.game_state.result.id

    {:ok, event} =
      ValidatorCreator.validate_and_create("remove-official-in-game", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("remove-player-in-team", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("remove-player-in-team", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("substitute-player", params, socket) do
    game_id = socket.assigns.game_state.result.id
    {:ok, event} = ValidatorCreator.validate_and_create("substitute-player", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-clock-time-and-period", params, socket) do
    game_id = socket.assigns.game_state.result.id

    {:ok, event} =
      ValidatorCreator.validate_and_create("update-clock-time-and-period", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("update-official-in-game", params, socket) do
    game_id = socket.assigns.game_state.result.id

    {:ok, event} =
      ValidatorCreator.validate_and_create("update-official-in-game", game_id, params)

    {:noreply,
     event
     |> react_and_update_game_state(game_id, socket)}
  end

  def handle_event("end-game-live-mode", _, socket) do
    Games.end_live_mode(socket.assigns.game_state.result.id)

    {:noreply, socket}
  end

  def handle_event("start-game-live-mode", _, socket) do
    Games.start_live_mode(socket.assigns.game_state.result.id)

    {:noreply, socket}
  end

  def handle_event("reset-game-live-mode", _, socket) do
    # TODO: Implement logic to reset game
    {:noreply, socket}
  end

  def handle_event("end-period", _, socket) do
    {:ok, event} =
      ValidatorCreator.validate_and_create("end-period", socket.assigns.game_state.result.id)

    {:noreply,
     event
     |> react_and_update_game_state(socket.assigns.game_state.result.id, socket)}
  end

  @spec handle_info({:game_reacted_to_event, any()}, any()) :: {:noreply, any()}
  def handle_info({:game_reacted_to_event, %{game_state: game_state}}, socket) do
    updated_socket =
      socket
      |> assign(:game_state, %{socket.assigns.game_state | result: game_state})

    {:noreply, updated_socket}
  end

  def handle_params(%{"game_id" => game_id}, _url, socket) do
    api_token = socket.assigns.api_token

    case ApiClient.get_game(game_id, api_token) do
      {:error, reason} ->
        Logger.error("Failed to fetch game state: #{inspect(reason)}")

        {:noreply,
         push_navigate(socket,
           to: ~p"/error"
         )}

      {:ok, _game_state} ->
        {:noreply, socket}
    end
  end

  defp react_and_update_game_state(event, game_id, socket) do
    reacted_game_state = Games.react_to_event(event, game_id)

    socket
    |> assign(:game_state, %{socket.assigns.game_state | result: reacted_game_state})
  end
end
