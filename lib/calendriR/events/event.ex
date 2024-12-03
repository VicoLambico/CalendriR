defmodule CalendriR.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :title, :string
    field :description, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :state, :string
    belongs_to :team, CalendriR.Teams.Team

    many_to_many :users, CalendriR.Accounts.User, join_through: "subscribes"

    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :start_time, :end_time, :state, :team_id])
    |> validate_required([:title, :description, :start_time, :end_time, :state])
    |> assoc_constraint(:team)
  end
end
