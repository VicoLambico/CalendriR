defmodule CalendriR.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias CalendriR.Repo

  alias CalendriR.Events.Event
  alias CalendriR.Teams.UserTeam

  @doc """
  Liste des événements filtrés par l'utilisateur et son équipe.
  """
  def list_events_for_user(user_id) do
    # On récupère les équipes de l'utilisateur
    user_teams = from(ut in UserTeam, where: ut.user_id == ^user_id, select: ut.team_id)

    # On filtre les événements associés aux équipes de l'utilisateur
    from(e in Event,
      join: t in assoc(e, :team),
      where: e.team_id in subquery(user_teams),
      preload: [team: t]
    )
    |> Repo.all()
  end
  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event) |> Repo.preload(:team)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id) |> Repo.preload(:team)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def create_event(attrs \\ %{}) do
  %Event{}
  |> Event.changeset(attrs)
  |> Repo.insert()
  |> case do
    {:ok, event} ->
      broadcast_event_update()

      # Preload the associated team after successful insert
      {:ok, Repo.preload(event, :team)}
    {:error, _changeset} = error ->
      error
  end
end


  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def update_event(%Event{} = event, attrs) do
  # Créer un changeset avec les données fournies
  changeset = Event.changeset(event, attrs)

  # Vérification de la validité du changeset
  if changeset.valid? do
    # Effectuer l'update dans la base de données
    case Repo.update(changeset) do
      {:ok, updated_event} ->
        broadcast_event_update()
        # Si l'update est réussi, précharger l'équipe
        updated_event = Repo.preload(updated_event, :team)
        {:ok, updated_event}

      {:error, changeset} ->
        # Si l'update échoue, retourner une erreur
        {:error, changeset}
    end
  else
    # Si le changeset n'est pas valide, retourner une erreur
    IO.inspect(changeset.errors, label: "Changeset errors")  # Pour aider au débogage
    {:error, changeset}
  end
end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

   @doc """
  Liste les événements auxquels un utilisateur est abonné.
  """
  def list_subscribed_events(user_id) do
    Repo.all(
      from e in Event,
        join: s in "subscribes",
        on: s.event_id == e.id,
        where: s.user_id == ^user_id,
        preload: [:team]
    )
  end

  defp broadcast_event_update do
    Phoenix.PubSub.broadcast(CalendriR.PubSub, "events_updates", :update_events)
  end
end
