defmodule CalendriR.Repo.Migrations.CreateIsFriend do
  use Ecto.Migration

  def change do
    create table(:is_friend) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :friend_id, references(:users, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "pending" # "pending", "accepted", "declined"

      timestamps()
    end

    create unique_index(:is_friend, [:user_id, :friend_id])
  end

end
