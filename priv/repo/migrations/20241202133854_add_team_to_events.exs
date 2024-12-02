defmodule CalendriR.Repo.Migrations.AddTeamToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      remove :team
      add :team_id, references(:teams, on_delete: :delete_all)
    end

    create index(:events, [:team_id])
  end
end
