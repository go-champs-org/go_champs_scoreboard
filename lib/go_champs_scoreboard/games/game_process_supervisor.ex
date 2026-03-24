defmodule GoChampsScoreboard.Games.GameProcessSupervisor do
  use DynamicSupervisor

  @behaviour GoChampsScoreboard.Games.GameProcessSupervisorBehavior

  @two_days_in_milliseconds 172_800_000

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @impl true
  def check_game_process(game_id) do
    case Registry.lookup(GoChampsScoreboard.Games.GameProcessRegistry, game_id) do
      [] -> {:error, :not_found}
      _ -> :ok
    end
  end

  @impl true
  def start_game_process(game_id) do
    child_spec = %{
      id: game_id,
      start: {GoChampsScoreboard.Games.GameProcess, :start_link, [game_id]},
      type: :worker,
      restart: :transient,
      shutdown: @two_days_in_milliseconds
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def stop_game_process(game_id) do
    case Registry.lookup(GoChampsScoreboard.Games.GameProcessRegistry, game_id) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      [] ->
        {:error, :not_found}
    end
  end
end
