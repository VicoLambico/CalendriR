defmodule CalendriR.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :teammates, :text
      add :admin, :text
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end