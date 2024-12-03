defmodule CalendriR.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias CalendriR.Repo
  alias CalendriR.Teams.{Team, UserTeam}

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, team} ->
        broadcast_team_update()
        {:ok, team}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_team} ->
        broadcast_team_update()
        {:ok, updated_team}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    case Repo.delete(team) do
      {:ok, team} ->
        broadcast_team_update()
        {:ok, team}

      {:error, _reason} ->
        {:error, "Failed to delete the team"}
    end
  end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  def add_users_to_team(team_id, user_ids) do
    user_ids
    |> Enum.map(fn user_id ->
      %CalendriR.Teams.UserTeam{}
      |> CalendriR.Teams.UserTeam.changeset(%{user_id: user_id, team_id: team_id})
      |> CalendriR.Repo.insert()
    end)
    |> Enum.each(fn
      {:ok, _user_team} -> :ok
      {:error, _changeset} -> :error
    end)

    # Diffusion après ajout des utilisateurs
    broadcast_team_update()
  end

  def manage_users_in_team(team_id, user_ids) do
    # Récupérer les utilisateurs actuels associés à cette équipe
    current_user_ids =
      Repo.all(from ut in UserTeam, where: ut.team_id == ^team_id, select: ut.user_id)

    # Utilisateurs à ajouter : ceux qui sont dans user_ids mais pas encore dans UserTeam
    users_to_add = user_ids -- current_user_ids

    # Utilisateurs à supprimer : ceux qui sont dans current_user_ids mais pas dans user_ids
    users_to_remove = current_user_ids -- user_ids

    # Supprimer les utilisateurs non sélectionnés (ceux qui sont dans current_user_ids mais pas dans user_ids)
    if users_to_remove != [] do
      remove_users_from_team(team_id, users_to_remove)
    end

    # Ajouter les utilisateurs non existants
    if users_to_add != [] do
      add_users_to_team(team_id, users_to_add)
    end
  end

  # Fonction pour supprimer des utilisateurs de l'équipe
  defp remove_users_from_team(team_id, user_ids) do
    user_ids
    |> Enum.each(fn user_id ->
      Repo.delete_all(from ut in UserTeam, where: ut.team_id == ^team_id and ut.user_id == ^user_id)
    end)

    # Diffusion après suppression des utilisateurs
    broadcast_team_update()
  end

  defp broadcast_team_update do
    Phoenix.PubSub.broadcast(CalendriR.PubSub, "teams_updates", :update_teams)
  end
end
