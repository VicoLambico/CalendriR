defmodule CalendriR.Events.Subscribe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribes" do
    belongs_to :user, CalendriR.Accounts.User
    belongs_to :event, CalendriR.Events.Event

    timestamps()
  end

  @doc """
  Creates a changeset for a subscription.
  """
  def changeset(subscribe, attrs) do
    subscribe
    |> cast(attrs, [:user_id, :event_id])
    |> validate_required([:user_id, :event_id])
    |> unique_constraint([:user_id, :event_id], name: :subscribes_user_id_event_id_index)
  end
end
