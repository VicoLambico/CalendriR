defmodule CalendriR.Teams.UserTeam do
  # Schema de la table user_team

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_team" do
    belongs_to :user, CalendriR.Accounts.User
    belongs_to :team, CalendriR.Teams.Team
    field :is_admin, :boolean, default: false
  end

  def changeset(user_team, attrs) do
    user_team
    |> cast(attrs, [:user_id, :team_id, :is_admin])
    |> validate_required([:user_id, :team_id])
    |> unique_constraint(:user_id, name: :user_team_user_id_team_id_index)
  end
end
