defmodule CalendriR.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :description, :string



    has_many :events, CalendriR.Events.Event, foreign_key: :team_id # Relation has_many

	  many_to_many :users, CalendriR.Accounts.User, join_through: "users_teams"
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name,  :description])
    |> validate_required([:name,  :description]) #:admin,
  end
end
