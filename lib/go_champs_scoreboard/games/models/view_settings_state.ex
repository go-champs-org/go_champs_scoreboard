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

  @spec rules_version(t() | nil) :: String.t()
  def rules_version(%__MODULE__{rules_version: rules_version}) when is_binary(rules_version),
    do: rules_version

  def rules_version(_view_settings_state), do: @default_rules_version
end
