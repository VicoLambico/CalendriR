defmodule CalendriR.Repo.Migrations.RemoveTeammatesFromTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove :teammates
      remove :admin, :string

      # Ajoute la clé étrangère vers `users`
      add :admin, references(:users, on_delete: :nothing)

    end
  end

end
