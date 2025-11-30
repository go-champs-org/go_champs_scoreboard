defmodule GoChampsScoreboard.Games.Games do
  alias GoChampsScoreboard.Games.Models.ProtestState
  alias GoChampsScoreboard.Games.Models.InfoState
  alias GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition
  alias GoChampsScoreboard.Events.ValidatorCreator
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Events.Handler
  alias GoChampsScoreboard.Games.Bootstrapper
  alias GoChampsScoreboard.Games.ResourceManager
  alias GoChampsScoreboard.Games.GameStateCache
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Messages.PubSub
  alias GoChampsScoreboard.Games.Models.GameState
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.ProtestState

  @spec find_or_bootstrap(String.t()) :: GameState.t()
  @spec find_or_bootstrap(String.t(), String.t()) :: GameState.t()
  @spec find_or_bootstrap(String.t(), String.t(), module()) :: GameState.t()
  def find_or_bootstrap(game_id, go_champs_token \\ "", resource_manager \\ ResourceManager) do
    case GameStateCache.get(game_id) do
      {:ok, nil} ->
        game_state =
          Bootstrapper.bootstrap()
          |> Bootstrapper.bootstrap_from_go_champs(game_id, go_champs_token)

        GameStateCache.update(game_state)

      {:ok, game} ->
        case game.live_state.state do
          :not_started ->
            updated_game =
              game
              |> Bootstrapper.bootstrap_from_go_champs(game.id, go_champs_token)

            GameStateCache.update(updated_game)

          :in_progress ->
            resource_manager.check_and_restart(game.id)

            game

          _ ->
            game
        end
    end
  end

  @spec start_live_mode(String.t(), module()) :: GameState.t()
  def start_live_mode(game_id, resource_manager \\ ResourceManager) do
    case GameStateCache.get(game_id) do
      {:ok, nil} ->
        raise RuntimeError, message: "Game not found"

      {:ok, _current_game_state} ->
        resource_manager.start_up(game_id)

        {:ok, start_event} =
          StartGameLiveModeDefinition.key()
          |> ValidatorCreator.validate_and_create(game_id)

        react_to_event(start_event, game_id)
    end
  end

  @spec end_live_mode(String.t(), module()) :: GameState.t()
  def end_live_mode(game_id, resource_manager \\ ResourceManager) do
    case GameStateCache.get(game_id) do
      {:ok, nil} ->
        raise RuntimeError, message: "Game not found"

      {:ok, _current_game_state} ->
        {:ok, end_event} =
          EndGameLiveModeDefinition.key()
          |> ValidatorCreator.validate_and_create(game_id)

        reacted_game = react_to_event(end_event, game_id)

        resource_manager.shut_down(game_id)

        reacted_game
    end
  end

  @spec react_to_event(Event.t(), GameState.t()) :: GameState.t()
  def react_to_event(event, game_id) do
    case GameStateCache.get(game_id) do
      {:ok, nil} ->
        raise RuntimeError, message: "Game not found"

      {:ok, current_game_state} ->
        new_game_state = Handler.handle(current_game_state, event)
        GameStateCache.update(new_game_state)

        PubSub.broadcast_game_reacted_to_event(event, new_game_state)

        new_game_state
    end
  end

  @spec update_team(GameState.t(), String.t(), TeamState.t()) :: GameState.t()
  def update_team(game_state, team_type, team) do
    case team_type do
      "home" ->
        %{game_state | home_team: team}

      "away" ->
        %{game_state | away_team: team}

      _ ->
        raise RuntimeError, message: "Invalid team type"
    end
  end

  @spec add_official(GameState.t(), OfficialState.t()) :: GameState.t()
  def add_official(game_state, official) do
    %{game_state | officials: [official | game_state.officials]}
  end

  @spec remove_official(GameState.t(), String.t()) :: GameState.t()
  def remove_official(game_state, official_id) do
    updated_officials = Enum.reject(game_state.officials, fn o -> o.id == official_id end)
    %{game_state | officials: updated_officials}
  end

  @spec update_official(GameState.t(), OfficialState.t()) :: GameState.t()
  def update_official(game_state, official) do
    updated_officials =
      Enum.map(game_state.officials, fn o ->
        if o.id == official.id do
          official
        else
          o
        end
      end)

    %{game_state | officials: updated_officials}
  end

  @spec update_clock_state(GameState.t(), GameClockState.t()) :: GameState.t()
  def update_clock_state(game_state, clock_state) do
    %{game_state | clock_state: clock_state}
  end

  @spec update_protest_state(GameState.t(), ProtestState.t()) :: GameState.t()
  def update_protest_state(game_state, protest_state) do
    %{game_state | protest: protest_state}
  end

  @spec update_info(GameState.t(), InfoState.t()) :: GameState.t()
  def update_info(game_state, info_state) do
    %{game_state | info: info_state}
  end
end
