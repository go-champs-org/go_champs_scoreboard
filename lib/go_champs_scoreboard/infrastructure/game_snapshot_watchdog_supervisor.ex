defmodule GoChampsScoreboard.Infrastructure.GameSnapshotWatchdogSupervisor do
  use DynamicSupervisor

  @behaviour GoChampsScoreboard.Infrastructure.GameSnapshotWatchdogSupervisorBehavior

  # 2 days in milliseconds
  @two_days_in_milliseconds 172_800_000

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @impl true
  def check_game_snapshot_watchdog(game_id) do
    children = DynamicSupervisor.which_children(__MODULE__)

    case Enum.find(children, fn {id, _, _, _} -> id == game_id end) do
      nil -> {:error, :not_found}
      _ -> :ok
    end
  end

  @impl true
  def start_game_snapshot_watchdog(game_id) do
    child_spec = %{
      id: game_id,
      start: {GoChampsScoreboard.Infrastructure.GameSnapshotWatchdog, :start_link, [game_id]},
      type: :worker,
      restart: :transient,
      shutdown: @two_days_in_milliseconds
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def stop_game_snapshot_watchdog(game_id) do
    case Registry.lookup(
           GoChampsScoreboard.Infrastructure.GameSnapshotWatchdogRegistry,
           game_id
         ) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      [] ->
        {:error, :not_found}
    end
  end
end
