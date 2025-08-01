defmodule GoChampsScoreboard.Sports.Basketball.EventLogsOperations do
  alias GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition
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

  @spec where_type_is_undoable(Ecto.Query.t()) :: Ecto.Query.t()
  def where_type_is_undoable(query) do
    unduable_types = [
      UpdatePlayerStatDefinition.key(),
      UpdateTeamStatDefinition.key(),
      SubstitutePlayerDefinition.key()
    ]

    from e in query,
      where: e.key in ^unduable_types
  end
end
