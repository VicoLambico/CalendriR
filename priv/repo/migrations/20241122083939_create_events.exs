defmodule CalendriR.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :description, :text
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :team, :text

      timestamps(type: :utc_datetime)
    end
  end
end
