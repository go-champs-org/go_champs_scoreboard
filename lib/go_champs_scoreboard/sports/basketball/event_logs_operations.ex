defmodule GoChampsScoreboard.Sports.Basketball.EventLogsOperations do
  import Ecto.Query

  @spec order_by(Ecto.Query.t()) :: Ecto.Query.t()
  def order_by(query) do
    from e in query,
      order_by: [
        asc: e.game_clock_period,
        desc: e.game_clock_time,
        asc: e.timestamp
      ],
      select: e
  end
end
