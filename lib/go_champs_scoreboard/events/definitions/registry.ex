defmodule GoChampsScoreboard.Events.Definitions.Registry do
  alias GoChampsScoreboard.Events.Definitions.AddCoachToTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.AddOfficialToGameDefinition
  alias GoChampsScoreboard.Events.Definitions.AddPlayerToTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Definitions.EndPeriodDefinition
  alias GoChampsScoreboard.Events.Definitions.GameTickDefinition
  alias GoChampsScoreboard.Events.Definitions.RemoveCoachInTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.RemoveOfficialInGameDefinition
  alias GoChampsScoreboard.Events.Definitions.RemovePlayerInTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.ResetGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Definitions.SubstitutePlayerDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateClockStateDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateClockTimeAndPeriodDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateCoachInTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateCoachStatDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateOfficialInGameDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerInTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition

  @registry %{
    AddCoachToTeamDefinition.key() => AddCoachToTeamDefinition,
    AddOfficialToGameDefinition.key() => AddOfficialToGameDefinition,
    AddPlayerToTeamDefinition.key() => AddPlayerToTeamDefinition,
    EndGameLiveModeDefinition.key() => EndGameLiveModeDefinition,
    EndPeriodDefinition.key() => EndPeriodDefinition,
    GameTickDefinition.key() => GameTickDefinition,
    RemoveCoachInTeamDefinition.key() => RemoveCoachInTeamDefinition,
    RemoveOfficialInGameDefinition.key() => RemoveOfficialInGameDefinition,
    RemovePlayerInTeamDefinition.key() => RemovePlayerInTeamDefinition,
    ResetGameLiveModeDefinition.key() => ResetGameLiveModeDefinition,
    StartGameLiveModeDefinition.key() => StartGameLiveModeDefinition,
    SubstitutePlayerDefinition.key() => SubstitutePlayerDefinition,
    UpdateCoachInTeamDefinition.key() => UpdateCoachInTeamDefinition,
    UpdateCoachStatDefinition.key() => UpdateCoachStatDefinition,
    UpdateClockStateDefinition.key() => UpdateClockStateDefinition,
    UpdateClockTimeAndPeriodDefinition.key() => UpdateClockTimeAndPeriodDefinition,
    UpdateOfficialInGameDefinition.key() => UpdateOfficialInGameDefinition,
    UpdatePlayerInTeamDefinition.key() => UpdatePlayerInTeamDefinition,
    UpdatePlayerStatDefinition.key() => UpdatePlayerStatDefinition,
    UpdateTeamStatDefinition.key() => UpdateTeamStatDefinition
  }

  @spec get_definition(String.t()) :: {:ok, module()} | {:error, :not_registered}
  def get_definition(key) do
    case Map.get(@registry, key) do
      nil -> {:error, :not_registered}
      definition -> {:ok, definition}
    end
  end
end
