defmodule CalendriR.Accounts.IsFriend do
  use Ecto.Schema
  import Ecto.Changeset

  schema "is_friend" do
    field :status, :string, default: "pending"

    belongs_to :user, CalendriR.Accounts.User, foreign_key: :user_id
    belongs_to :friend, CalendriR.Accounts.User, foreign_key: :friend_id

    timestamps()
  end

  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:user_id, :friend_id, :status])
    |> validate_required([:user_id, :friend_id, :status])
    |> unique_constraint([:user_id, :friend_id])
  end
end
