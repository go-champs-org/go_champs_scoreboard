defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaBoxScore do
  defmodule Player do
    @moduledoc """
    Player struct for FIBA boxscore report.
    """

    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            number: integer(),
            stats_values: %{String.t() => number()}
          }

    defstruct [
      :id,
      :name,
      :number,
      :stats_values
    ]
  end

  defmodule Team do
    @moduledoc """
    Team struct for FIBA boxscore report.
    """

    @type t :: %__MODULE__{
            name: String.t(),
            points_by_period: %{String.t() => integer()},
            total_points: integer(),
            total_player_stats: %{String.t() => number()},
            players: list(Player.t())
          }

    defstruct [
      :name,
      :points_by_period,
      :total_points,
      :total_player_stats,
      :players
    ]
  end

  @type t :: %__MODULE__{
          number: String.t(),
          location: String.t(),
          datetime: DateTime.t(),
          actual_start_datetime: DateTime.t() | nil,
          actual_end_datetime: DateTime.t() | nil,
          tournament_name: String.t(),
          organization_name: String.t(),
          organization_logo_url: String.t(),
          web_url: String.t() | nil,
          home_team: Team.t(),
          away_team: Team.t()
        }

  defstruct [
    :number,
    :location,
    :datetime,
    :actual_start_datetime,
    :actual_end_datetime,
    :tournament_name,
    :organization_name,
    :organization_logo_url,
    :web_url,
    :home_team,
    :away_team
  ]
end
