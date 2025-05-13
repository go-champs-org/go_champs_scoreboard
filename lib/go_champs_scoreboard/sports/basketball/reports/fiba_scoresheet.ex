defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet do
  defmodule Foul do
    @moduledoc """
    Foul struct for FIBA scoresheet.
    """

    # Define valid foul types
    # Personal, Technical, Anti Sportsmanship (U), Disqualifying, Disqualifying Fighting (F), Technical due other persons (B)
    @valid_fouls_types ["P", "T", "U", "D", "F", "B"]

    @valid_extra_actions ["1", "2", "3", "C"]

    @type t :: %__MODULE__{
            type: String.t(),
            period: Integer.t(),
            extra_action: String.t()
          }

    defstruct [
      :type,
      :period,
      :extra_action
    ]

    @doc """
    Creates a new PointScore struct with validation
    """
    def new(attrs) do
      type = Map.get(attrs, :type)
      extra_action = Map.get(attrs, :extra_action)

      if type in @valid_fouls_types and extra_action in @valid_extra_actions do
        struct(__MODULE__, attrs)
      else
        {:error,
         "Invalid foul type: #{type}. Must be one of: #{Enum.join(@valid_fouls_types, ", ")}"}
      end
    end
  end

  defmodule Player do
    @moduledoc """
    Player struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            number: String.t(),
            fouls: list(Foul.t()),
            has_started: boolean(),
            has_played: boolean(),
            is_captain: boolean()
          }

    defstruct [
      :id,
      :name,
      :number,
      :fouls,
      :has_started,
      :has_played,
      :is_captain
    ]
  end

  defmodule Coach do
    @moduledoc """
    Coach struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            fouls: list(Foul.t())
          }

    defstruct [
      :id,
      :name,
      :fouls
    ]
  end

  defmodule PointScore do
    @moduledoc """
    PointScore struct for FIBA scoresheet.
    """

    # Define valid point types
    @valid_point_types ["FT", "2PT", "3PT"]

    @type t :: %__MODULE__{
            type: String.t(),
            player_number: Integer.t(),
            period: Integer.t(),
            is_last_of_period: boolean()
          }

    defstruct [
      :type,
      :player_number,
      :period,
      :is_last_of_period
    ]

    @doc """
    Creates a new PointScore struct with validation
    """
    def new(attrs) do
      type = Map.get(attrs, :type)

      if type in @valid_point_types do
        struct(__MODULE__, attrs)
      else
        {:error,
         "Invalid point type: #{type}. Must be one of: #{Enum.join(@valid_point_types, ", ")}"}
      end
    end
  end

  defmodule Timeout do
    @moduledoc """
    Timeout struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            period: Integer.t(),
            minute: Integer.t()
          }

    defstruct [
      :period,
      :minute
    ]
  end

  defmodule Team do
    @moduledoc """
    Team struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            name: String.t(),
            players: list(Player.t()),
            coach: Coach.t(),
            assistant_coach: Coach.t(),
            all_fouls: list(Foul.t()),
            timeouts: list(Timeout.t()),
            running_score: %{Integer.t() => PointScore.t()},
            score: integer()
          }

    defstruct [
      :name,
      :players,
      :coach,
      :assistant_coach,
      :all_fouls,
      :timeouts,
      :running_score,
      :score
    ]
  end

  defmodule Header do
    @moduledoc """
    Header struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            game_id: String.t(),
            location: String.t(),
            date: String.t(),
            crew_chief: String.t(),
            referee_1: String.t(),
            referee_2: String.t()
          }

    defstruct [
      :game_id,
      :location,
      :date,
      :crew_chief,
      :referee_1,
      :referee_2
    ]
  end

  @type t :: %__MODULE__{
          game_id: String.t(),
          tournament_name: String.t(),
          header: Header.t(),
          team_a: Team.t(),
          team_b: Team.t()
        }

  defstruct [:game_id, :tournament_name, :header, :team_a, :team_b]
end
