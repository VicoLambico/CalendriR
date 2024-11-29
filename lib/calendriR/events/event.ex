defmodule CalendriR.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :state, :string
    field :description, :string
    field :title, :string
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime

    timestamps(type: :utc_datetime)
    belongs_to :team, CalendriR.Teams.Team
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :start_time, :end_time, :team, :state])
    |> validate_required([:title, :description, :start_time, :end_time, :team, :state])
    |> validate_inclusion(:state, ["to do", "in progress", "terminate"])
  end
end
