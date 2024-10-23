defmodule GoChampsScoreboard.GameTickerSupervisorBehavior do
  @callback get_game_ticker(String.t()) :: :ok | {:error, any()}
  @callback start_game_ticker(String.t()) :: :ok | {:error, any()}
  @callback stop_game_ticker(String.t()) :: :ok | {:error, any()}
end
