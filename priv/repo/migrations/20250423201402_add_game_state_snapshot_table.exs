defmodule GoChampsScoreboard.Repo.Migrations.AddGameStateSnapshotTable do
  use Ecto.Migration

  def change do
    create table(:game_snapshots, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_log_id, references(:event_logs, type: :uuid, on_delete: :delete_all), null: false
      add :state, :map, null: false

      timestamps()
    end

    create index(:game_snapshots, [:event_log_id])
  end
end
