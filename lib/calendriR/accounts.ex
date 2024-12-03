defmodule CalendriR.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias CalendriR.Repo

  alias CalendriR.Accounts.{User, UserToken, UserNotifier,IsFriend}
  alias CalendriR.Events.Subscribe
  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
def get_user_by_email_or_username_and_password(identifier, password)
when is_binary(identifier) and is_binary(password) do
user =
User
|> where([u], u.email == ^identifier or u.username == ^identifier)
|> Repo.one()

if User.valid_password?(user, password), do: user
end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end




@doc """
  Liste tous les utilisateurs.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Envoie une demande d'amitié.
  """
def request_friendship(user_id, friend_id) do
  %IsFriend{}
  |> IsFriend.changeset(%{user_id: user_id, friend_id: friend_id, status: "pending"})
  |> Repo.insert()
  |> case do
    {:ok, _friendship} ->
      broadcast_friendship_update(user_id)
      broadcast_friendship_update(friend_id)
      {:ok, :success}

    {:error, changeset} ->
      {:error, changeset}
  end
end




def respond_to_friend_request(user_id, friend_id, "accept") do
  Repo.transaction(fn ->
    case Repo.get_by(IsFriend, user_id: friend_id, friend_id: user_id) do
      nil ->
        Repo.rollback(:not_found)

      friendship ->
        # Met à jour le statut à "accepted"
        friendship
        |> Ecto.Changeset.change(status: "accepted")
        |> Repo.update!()

        # Vérifie si une relation inversée existe déjà
        unless Repo.get_by(IsFriend, user_id: user_id, friend_id: friend_id) do
          Repo.insert!(%IsFriend{user_id: user_id, friend_id: friend_id, status: "accepted"})
        end
    end
  end)
  |> case do
    {:ok, _result} ->
      broadcast_friendship_update(user_id)
      broadcast_friendship_update(friend_id)
      {:ok, :success}

    {:error, reason} ->
      {:error, reason}
  end
end


def respond_to_friend_request(user_id, friend_id, "decline") do
  case Repo.get_by(IsFriend, user_id: friend_id, friend_id: user_id) do
    nil ->
      {:error, :not_found}

    friendship ->
      # Supprime la relation
      case Repo.delete(friendship) do
        {:ok, _} ->
          # Diffuse les mises à jour si la suppression réussit
          broadcast_friendship_update(user_id)
          broadcast_friendship_update(friend_id)
          {:ok, :deleted}

        {:error, reason} ->
          {:error, reason}
      end
  end
end


  def respond_to_friend_request(_, _, _) do
    {:error, :invalid_action}
  end


  @doc """
  Liste les demandes d'amis entrantes (en attente).
  """
  def list_incoming_friend_requests(user_id) do
    from(f in IsFriend,
      where: f.friend_id == ^user_id and f.status == "pending",
      preload: [:user]  # Assurez-vous que votre modèle `IsFriend` contient bien les préchargements nécessaires
    )
    |> Repo.all()
  end


  # Vérifie si les deux utilisateurs sont amis avec statut "accepted"
  def is_friend?(user_id1, user_id2) do
    case Repo.get_by(IsFriend, user_id: user_id1, friend_id: user_id2, status: "accepted") do
      nil -> false
      _friendship -> true
    end
  end

  def list_friends(user_id) do
    Repo.all(
      from f in IsFriend,
        where: (f.user_id == ^user_id ) and f.status == "accepted",
        preload: [:user, :friend]
    )
    |> Enum.filter(fn f -> f.user_id != f.friend_id end) # Exclure les auto-amitiés éventuelles
  end


# Supprimer la relation d'amitié
def remove_friend(user_id, friend_id) do
  Repo.transaction(fn ->
    # Supprime la relation bidirectionnelle
    Repo.delete_all(
      from f in IsFriend,
      where: (f.user_id == ^user_id and f.friend_id == ^friend_id) or (f.user_id == ^friend_id and f.friend_id == ^user_id)
    )
  end)

  broadcast_friendship_update(user_id)
  broadcast_friendship_update(friend_id)
  :ok
end


defp broadcast_friendship_update(user_id) do
  Phoenix.PubSub.broadcast(CalendriR.PubSub, "friendship_updates:#{user_id}", :update_friendship)
end


 # Ajouter une relation entre un utilisateur et un événement (abonnement)
 # Ajouter une relation entre un utilisateur et un événement (abonnement)
def subscribe_to_event(user_id, event_id) do
  changeset =
    %Subscribe{}
    |> Subscribe.changeset(%{user_id: user_id, event_id: event_id})

  case Repo.insert(changeset) do
    {:ok, _subscription} ->
      # Diffusion de l'événement
      broadcast_subscription_update(user_id, event_id)
      {:ok, "Successfully subscribed"}

    {:error, changeset} ->
      {:error, changeset}
  end
end



# Vérifie si un utilisateur est abonné à un événement
def subscribed?(user_id, event_id) do
  Repo.exists?(
    from sub in Subscribe,
    where: sub.user_id == ^user_id and sub.event_id == ^event_id
  )
end

def unsubscribe_from_event(user_id, event_id) do
  # Trouver l'abonnement correspondant
  subscription =
    Repo.one(from sub in Subscribe, where: sub.user_id == ^user_id and sub.event_id == ^event_id)

  # Si un abonnement existe, le supprimer
  if subscription do
    case Repo.delete(subscription) do
      {:ok, _deleted_subscription} ->
        # Diffusion de la mise à jour d'abonnement
        broadcast_subscription_update(user_id, event_id)
        {:ok, "Successfully unsubscribed"}

      {:error, _reason} ->
        {:error, "Failed to unsubscribe"}
    end
  else
    {:error, "No subscription found"}
  end
end



# Diffuse une mise à jour d'abonnement
defp broadcast_subscription_update(user_id, event_id) do
  Phoenix.PubSub.broadcast(
    CalendriR.PubSub,
    "subscription_updates:#{user_id}",
    {:update_subscription, event_id}
  )
end



end
