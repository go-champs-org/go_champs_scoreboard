defmodule GoChampsScoreboard.Games.GameStateCache do
  @moduledoc """
  Cache operations for game states using Redis.
  """

  alias GoChampsScoreboard.Games.Models.GameState

  @two_days_in_seconds 172_800

  @spec get(String.t()) :: {:ok, GameState.t()} | {:ok, nil} | {:error, any()}
  def get(game_id) do
    case Redix.command(:games_cache, ["GET", cache_key(game_id)]) do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, game_json} ->
        {:ok, GameState.from_json(game_json)}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec update(GameState.t()) :: GameState.t()
  def update(game_state) do
    Redix.command(:games_cache, [
      "SET",
      cache_key(game_state.id),
      game_state,
      "EX",
      @two_days_in_seconds
    ])

    game_state
  end

  @spec cache_key(String.t()) :: String.t()
  defp cache_key(game_id), do: "game_state:#{game_id}"
end
