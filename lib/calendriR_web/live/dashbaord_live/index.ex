defmodule CalendriRWeb.DashbaordLive.Index do
  use CalendriRWeb, :live_view
  alias CalendriR.Events

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    # Récupérer les événements abonnés par l'utilisateur actuel
    subscribed_events = Events.list_subscribed_events(current_user.id)

    {:ok, assign(socket, subscribed_events: subscribed_events)}
  end

end
