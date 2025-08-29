defmodule GoChampsScoreboard.Games.Models.GameState do
  alias GoChampsScoreboard.Games.Models.TeamState
  alias GoChampsScoreboard.Games.Models.PlayerState
  alias GoChampsScoreboard.Games.Models.CoachState
  alias GoChampsScoreboard.Games.Models.GameClockState
  alias GoChampsScoreboard.Games.Models.LiveState
  alias GoChampsScoreboard.Games.Models.ViewSettingsState
  alias GoChampsScoreboard.Games.Models.OfficialState
  alias GoChampsScoreboard.Games.Models.InfoState
  alias GoChampsScoreboard.Games.Models.ProtestState

  @type t :: %__MODULE__{
          id: String.t(),
          away_team: TeamState,
          home_team: TeamState,
          sport_id: String.t(),
          clock_state: GameClockState,
          live_state: LiveState,
          view_settings_state: ViewSettingsState,
          officials: [OfficialState.t()],
          protest: ProtestState.t(),
          info: InfoState.t()
        }
  defstruct [
    :id,
    :away_team,
    :home_team,
    :clock_state,
    :sport_id,
    :live_state,
    :view_settings_state,
    :officials,
    :protest,
    :info
  ]

  @spec new(
          String.t(),
          TeamState.t(),
          TeamState.t(),
          GameClockState.t(),
          LiveState.t(),
          String.t(),
          ViewSettingsState.t(),
          [OfficialState.t()],
          ProtestState.t(),
          InfoState.t()
        ) :: t()
  def new(
        id,
        away_team,
        home_team,
        clock_state,
        live_state,
        sport_id \\ "basketball",
        view_settings_state \\ ViewSettingsState.new(),
        officials \\ [],
        protest \\ ProtestState.new(:none, "", :no_protest),
        info \\ InfoState.new(DateTime.utc_now())
      ) do
    %__MODULE__{
      id: id,
      away_team: away_team,
      home_team: home_team,
      clock_state: clock_state,
      sport_id: sport_id,
      live_state: live_state,
      view_settings_state: view_settings_state,
      officials: officials,
      protest: protest,
      info: info
    }
  end

  @spec from_json(String.t()) :: t()
  def from_json(curr_game_json) do
    Poison.decode!(curr_game_json,
      as: %__MODULE__{
        away_team: %TeamState{
          coaches: [%CoachState{}],
          players: [%PlayerState{}]
        },
        home_team: %TeamState{
          coaches: [%CoachState{}],
          players: [%PlayerState{}]
        },
        clock_state: %GameClockState{},
        live_state: %LiveState{},
        view_settings_state: %ViewSettingsState{},
        officials: [%OfficialState{}],
        protest: %ProtestState{},
        info: %InfoState{}
      }
    )
  end

  defimpl String.Chars do
    def to_string(game) do
      Poison.encode!(game)
    end
  end
end
