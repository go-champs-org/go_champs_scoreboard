defmodule GoChampsScoreboard.Repo.Migrations.AddGameClockToEventLogs do
  use Ecto.Migration

  def change do
    alter table(:event_logs) do
      add :game_clock_time, :integer
      add :game_clock_period, :integer
    end

    create index(:event_logs, [:game_id, :game_clock_period, :game_clock_time])
  end
end
