defmodule GoChampsScoreboard.Games.Models.ViewSettingsState do
  @default_rules_version "fiba-2024"

  @type t :: %__MODULE__{
          view: String.t(),
          available_views: [String.t()],
          rules_version: String.t()
        }

  defstruct [:view, :available_views, rules_version: @default_rules_version]

  @spec new(String.t(), [String.t()], String.t()) :: t()
  def new(
        view \\ "basketball-medium-stats",
        available_views \\ [],
        rules_version \\ @default_rules_version
      ) do
    %__MODULE__{
      view: view,
      available_views: available_views,
      rules_version: rules_version
    }
  end

  @spec default_rules_version() :: String.t()
  def default_rules_version, do: @default_rules_version
end
