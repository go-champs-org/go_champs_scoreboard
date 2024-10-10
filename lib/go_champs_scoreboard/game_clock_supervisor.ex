defmodule GoChampsScoreboard.GameClockSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: GoChampsScoreboard.GameRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_game_clock(game_id) do
    Supervisor.start_child(__MODULE__, {GoChampsScoreboard.GameClock, game_id})
  end
end
