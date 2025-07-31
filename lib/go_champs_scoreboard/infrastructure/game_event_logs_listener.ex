defmodule GoChampsScoreboard.Infrastructure.GameEventLogsListener do
  use GenServer

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def init(game_id) do
    {:ok, %{game_id: game_id}}
  end

  def handle_call(:process_pending_messages, _from, state) do
    {:messages, pending_messages} = Process.info(self(), :messages)

    Enum.each(pending_messages, fn message ->
      handle_info(message, state)
    end)

    {:reply, :ok, state}
  end

  defp via_tuple(game_id) do
    {:via, Registry, {GoChampsScoreboard.Infrastructure.GameEventLogsListenerRegistry, game_id}}
  end
end
