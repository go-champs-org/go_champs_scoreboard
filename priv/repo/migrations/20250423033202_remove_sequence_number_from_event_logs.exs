defmodule GoChampsScoreboard.Repo.Migrations.RemoveSequenceNumberFromEventLogs do
  use Ecto.Migration

  def change do
    drop index(:event_logs, [:game_id, :sequence_number])

    alter table(:event_logs) do
      remove :sequence_number
    end
  end
end
