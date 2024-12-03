defmodule CalendriR.Repo.Migrations.CreateSubscribe do
  use Ecto.Migration

  def change do
    create table(:subscribes) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:subscribes, [:user_id, :event_id])
  end
end
