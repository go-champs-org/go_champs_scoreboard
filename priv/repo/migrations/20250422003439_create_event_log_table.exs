defmodule GoChampsScoreboard.Repo.Migrations.CreateEventLogTable do
  use Ecto.Migration

  def change do
    create table(:event_logs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :game_id, :uuid, null: false
      add :key, :string, null: false
      add :timestamp, :utc_datetime_usec, null: false
      add :sequence_number, :integer, null: false
      add :payload, :map

      timestamps()
    end

    create index(:event_logs, [:game_id, :sequence_number])
    create index(:event_logs, [:game_id, :timestamp])
  end
end
