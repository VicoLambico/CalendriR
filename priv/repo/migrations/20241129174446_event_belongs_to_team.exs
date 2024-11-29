defmodule CalendriR.Repo.Migrations.EventBelongsToTeam do
  use Ecto.Migration

  def change do
	alter table(:events) do
		add :team_id, references(:teams)
	end
  end
end
