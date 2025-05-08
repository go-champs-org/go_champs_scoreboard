defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet do
  defmodule Foul do
    @moduledoc """
    Foul struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            type: String.t(),
            quarter: Integer.t()
          }

    defstruct [
      :type,
      :quarter
    ]
  end

  defmodule Player do
    @moduledoc """
    Player struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            number: String.t(),
            fouls: list(Foul.t())
          }

    defstruct [
      :id,
      :name,
      :number,
      :fouls
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
            is_last_of_quarter: boolean()
          }

    defstruct [
      :type,
      :player_number,
      :is_last_of_quarter
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

  defmodule Team do
    @moduledoc """
    Team struct for FIBA scoresheet.
    """

    @type t :: %__MODULE__{
            name: String.t(),
            players: list(Player.t()),
            coaches: list(Coach.t()),
            all_fouls: list(Foul.t()),
            running_score: %{Integer.t() => PointScore.t()},
            score: integer()
          }

    defstruct [
      :name,
      :players,
      :coaches,
      :all_fouls,
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
