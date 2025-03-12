defmodule GoChampsScoreboard.Games.Models.ViewSettingsState do
  @type t :: %__MODULE__{
          view: String.t()
        }

  defstruct [:view]

  @spec new(String.t()) :: t()
  def new(view \\ "basketball-medium") do
    %__MODULE__{
      view: view
    }
  end
end
