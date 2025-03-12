defmodule GoChampsScoreboard.Games.Models.GameState do
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.LiveState
  alias GoChampsScoreboard.Games.Models.ViewSettingsState

  @type t :: %__MODULE__{
          id: String.t(),
          away_team: TeamState,
          home_team: TeamState,
          sport_id: String.t(),
          clock_state: GameClockState,
          live_state: LiveState,
          view_settings_state: ViewSettingsState
        }
  defstruct [
    :id,
    :away_team,
    :home_team,
    :clock_state,
    :sport_id,
    :live_state,
    :view_settings_state
  ]

  @spec new(
          String.t(),
          TeamState.t(),
          TeamState.t(),
          GameClockState.t(),
          LiveState.t(),
          String.t(),
          ViewSettingsState.t()
        ) :: t()
  def new(
        id,
        away_team,
        home_team,
        clock_state,
        live_state,
        sport_id \\ "basketball",
        view_settings_state \\ ViewSettingsState.new()
      ) do
    %__MODULE__{
      id: id,
      away_team: away_team,
      home_team: home_team,
      clock_state: clock_state,
      sport_id: sport_id,
      live_state: live_state,
      view_settings_state: view_settings_state
    }
  end

  @spec from_json(String.t()) :: t()
  def from_json(curr_game_json) do
    Poison.decode!(curr_game_json,
      as: %__MODULE__{
        away_team: %TeamState{
          players: [%PlayerState{}]
        },
        home_team: %TeamState{
          players: [%PlayerState{}]
        },
        clock_state: %GameClockState{},
        live_state: %LiveState{},
        view_settings_state: %ViewSettingsState{}
      }
    )
  end

  defimpl String.Chars do
    def to_string(game) do
      Poison.encode!(game)
    end
  end
end
