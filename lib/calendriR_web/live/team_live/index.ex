defmodule CalendriRWeb.TeamLive.Index do
  use CalendriRWeb, :live_view

  alias CalendriR.Teams
  alias CalendriR.Teams.Team
#TODO : regler le problème lorsque delete, le liveview ne broacast pas correctement
  @impl true
  def mount(_params, _session, socket) do
    # Abonnement aux mises à jour des équipes
    Phoenix.PubSub.subscribe(CalendriR.PubSub, "teams_updates")
    current_user = socket.assigns.current_user.id

    # Récupérer uniquement les équipes où l'utilisateur est membre
    teams = Teams.list_teams_for_user(current_user)
    {:ok, stream(socket, :teams, teams)}
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Team")
    |> assign(:team, Teams.get_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Team")
    |> assign(:team, %Team{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Teams")
    |> assign(:team, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Teams.get_team!(id)
    {:ok, _} = Teams.delete_team(team)

    {:noreply, stream_delete(socket, :teams, team)}
  end

  @impl true
  def handle_info(:update_teams, socket) do
    # Récupérer la liste des équipes après une mise à jour
    current_user = socket.assigns.current_user.id

    updated_teams = Teams.list_teams_for_user(current_user)

    # Rafraîchir les équipes dans la vue
    {:noreply, stream(socket, :teams, updated_teams)}
  end
  @impl true
  def handle_info({CalendriRWeb.TeamLive.FormComponent, {:saved, team}}, socket) do

    {:noreply, stream_insert(socket, :teams, team)}
  end


end
