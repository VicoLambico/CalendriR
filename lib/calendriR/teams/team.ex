defmodule CalendriR.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :description, :string
    field :teammates, :string
    field :admin, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :teammates, :admin, :description])
    |> validate_required([:name, :teammates, :admin, :description])
  end
end
