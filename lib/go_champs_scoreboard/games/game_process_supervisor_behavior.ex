defmodule GoChampsScoreboard.Games.GameProcessSupervisorBehavior do
  @callback check_game_process(String.t()) :: :ok | {:error, any()}
  @callback start_game_process(String.t()) :: {:ok, pid()} | {:error, any()}
  @callback stop_game_process(String.t()) :: :ok | {:error, any()}
end
