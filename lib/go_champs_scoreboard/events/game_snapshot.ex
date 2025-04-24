defmodule GoChampsScoreboard.Events.GameSnapshot do
  use Ecto.Schema
  use GoChampsScoreboard.Schema
  import Ecto.Changeset

  alias GoChampsScoreboard.Events.EventLog
  alias GoChampsScoreboard.Games.Models.GameState

  @type t :: %__MODULE__{
          event_log: EventLog.t(),
          state: GameState.t()
        }

  schema "game_snapshots" do
    field :state, :map,
      default: %{},
      type: GameState

    belongs_to :event_log, EventLog,
      foreign_key: :event_log_id,
      references: :id,
      type: Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game_snapshot, attrs) do
    game_snapshot
    |> cast(attrs, [:id, :event_log_id, :state])
    |> validate_required([:event_log_id, :state])
    |> foreign_key_constraint(:event_log_id)
  end
end
