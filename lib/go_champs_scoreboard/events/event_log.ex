defmodule GoChampsScoreboard.Events.EventLog do
  use Ecto.Schema
  use GoChampsScoreboard.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          key: String.t(),
          game_id: Ecto.UUID.t(),
          timestamp: DateTime.t(),
          payload: any()
        }

  schema "event_logs" do
    field :timestamp, :utc_datetime_usec
    field :key, :string
    field :payload, :map
    field :game_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_log, attrs) do
    event_log
    |> cast(attrs, [:id, :game_id, :key, :timestamp, :payload])
    |> validate_required([:game_id, :key, :timestamp])
  end
end
