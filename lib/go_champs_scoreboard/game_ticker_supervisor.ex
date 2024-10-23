defmodule GoChampsScoreboard.GameTickerSupervisor do
  use Supervisor
  @behaviour GoChampsScoreboard.GameTickerSupervisorBehavior

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: GoChampsScoreboard.GameRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @impl true
  def start_game_ticker(game_id) do
    Supervisor.start_child(__MODULE__, {GoChampsScoreboard.GameTicker, game_id})
  end

  @impl true
  def get_game_ticker(game_id) do
    case Registry.lookup(GoChampsScoreboard.GameRegistry, game_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  @impl true
  def stop_game_ticker(game_id) do
    case Registry.lookup(GoChampsScoreboard.GameRegistry, game_id) do
      [{pid, _}] -> Supervisor.terminate_child(__MODULE__, pid)
      [] -> {:error, :not_found}
    end
  end

  def stop_all_game_tickers do
    Registry.select(GoChampsScoreboard.GameRegistry, [{{:"$1", :"$2", :"$3"}, [], [:"$1"]}])
    |> Enum.each(&Supervisor.terminate_child(__MODULE__, &1))
  end
end
