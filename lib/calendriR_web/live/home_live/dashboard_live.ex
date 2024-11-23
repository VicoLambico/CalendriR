defmodule CalendriRWeb.DashboardLive do
  use CalendriRWeb, :live_view

  # Montre les données initiales à l'ouverture de la page
  @impl true
  def mount(_params, session, socket) do
    current_user = CalendriR.Accounts.get_user_by_session_token(session["user_token"])

    if current_user do
      {:ok, assign(socket, current_user: current_user)}
    else
      {:error, :unauthorized}
    end
  end
  # Gère les événements générés par les utilisateurs
  @impl true
  def handle_event("mark_done", _params, socket) do
    {:noreply, assign(socket, message: "Task marked as done!")}
  end

  # Génère le HTML de la page
  @impl true
  def render(assigns) do
    ~H"""

    """
  end
end
