defmodule GoChampsScoreboard.Events.EventLog do
  use Ecto.Schema
  use GoChampsScoreboard.Schema
  import Ecto.Changeset
  alias GoChampsScoreboard.Events.GameSnapshot

  @type t :: %__MODULE__{
          key: String.t(),
          game_id: Ecto.UUID.t(),
          timestamp: DateTime.t(),
          payload: map(),
          game_clock_time: integer(),
          game_clock_period: integer()
        }

  schema "event_logs" do
    field :timestamp, :utc_datetime_usec
    field :key, :string
    field :payload, :map
    field :game_id, Ecto.UUID
    # Time in seconds
    field :game_clock_time, :integer
    # Period number
    field :game_clock_period, :integer

    has_one :snapshot, GameSnapshot, foreign_key: :event_log_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_log, attrs) do
    event_log
    |> cast(attrs, [
      :id,
      :game_id,
      :key,
      :timestamp,
      :payload,
      :game_clock_time,
      :game_clock_period
    ])
    |> validate_required([:game_id, :key, :timestamp, :game_clock_time, :game_clock_period])
  end

  @spec from_json(String.t()) :: t()
  def from_json(curr_event_log_json) do
    decoded = Poison.decode!(curr_event_log_json, as: %__MODULE__{})

    # Convert timestamp strings to DateTime structs
    %{
      decoded
      | timestamp: parse_datetime(decoded.timestamp),
        inserted_at: parse_datetime(decoded.inserted_at),
        updated_at: parse_datetime(decoded.updated_at)
    }
  end

  # Private helper function to parse DateTime strings
  defp parse_datetime(nil), do: nil
  defp parse_datetime(%DateTime{} = dt), do: dt

  defp parse_datetime(timestamp_string) when is_binary(timestamp_string) do
    case DateTime.from_iso8601(timestamp_string) do
      {:ok, datetime, _offset} -> datetime
      # fallback to original if parsing fails
      {:error, _reason} -> timestamp_string
    end
  end

  defp parse_datetime(other), do: other

  defimpl String.Chars do
    def to_string(event_log) do
      Poison.encode!(event_log)
    end
  end
end
