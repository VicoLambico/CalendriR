defmodule CalendriRWeb.EventLive.Show do
  use CalendriRWeb, :live_view

  alias CalendriR.{Accounts, Events}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    event = Events.get_event!(id)
    is_subscribed = Accounts.subscribed?(socket.assigns.current_user.id, event.id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:event, event)
     |> assign(:is_subscribed, is_subscribed)}
  end

  # Gérer l'abonnement/désabonnement
  @impl true
  def handle_event("subscribe", %{"event_id" => event_id}, socket) do
    _event = socket.assigns.event
    case Accounts.subscribe_to_event(socket.assigns.current_user.id, event_id) do
      {:ok, _} ->
        {:noreply, assign(socket, :is_subscribed, true)}
      {:error, _} ->
        {:noreply, socket}
    end
  end
  @impl true
  def handle_event("unsubscribe", %{"event_id" => event_id}, socket) do
    _event = socket.assigns.event
    case Accounts.unsubscribe_from_event(socket.assigns.current_user.id, event_id) do
      {:ok, _} ->
        {:noreply, assign(socket, :is_subscribed, false)}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Event"
  defp page_title(:edit), do: "Edit Event"
end
