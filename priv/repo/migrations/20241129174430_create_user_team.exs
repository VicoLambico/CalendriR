defmodule CalendriR.Repo.Migrations.CreateUserTeam do
  use Ecto.Migration

  def change do
	create table(:user_team) do
		add :user_id, references(:users, on_delete: :delete_all), null: false
		add :team_id, references(:teams, on_delete: :delete_all), null: false
	end

	create unique_index(:user_team, [:user_id, :team_id])
  end



end
