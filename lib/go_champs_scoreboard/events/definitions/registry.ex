defmodule GoChampsScoreboard.Events.Definitions.Registry do
  alias GoChampsScoreboard.Events.Definitions.AddPlayerToTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.EndGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Definitions.GameTickDefinition
  alias GoChampsScoreboard.Events.Definitions.RemovePlayerInTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.StartGameLiveModeDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateClockStateDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerInTeamDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdatePlayerStatDefinition
  alias GoChampsScoreboard.Events.Definitions.UpdateTeamStatDefinition

  @registry %{
    AddPlayerToTeamDefinition.key() => AddPlayerToTeamDefinition,
    EndGameLiveModeDefinition.key() => EndGameLiveModeDefinition,
    GameTickDefinition.key() => GameTickDefinition,
    RemovePlayerInTeamDefinition.key() => RemovePlayerInTeamDefinition,
    StartGameLiveModeDefinition.key() => StartGameLiveModeDefinition,
    UpdateClockStateDefinition.key() => UpdateClockStateDefinition,
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