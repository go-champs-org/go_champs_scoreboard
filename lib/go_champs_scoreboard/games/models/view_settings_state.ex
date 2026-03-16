defmodule GoChampsScoreboard.Games.Models.ViewSettingsState do
  @type t :: %__MODULE__{
          view: String.t(),
          available_views: [String.t()]
        }

  defstruct [:view, :available_views]

  @spec new(String.t(), [String.t()]) :: t()
  def new(view \\ "basketball-medium", available_views \\ []) do
    %__MODULE__{
      view: view,
      available_views: available_views
    }
  end
end
