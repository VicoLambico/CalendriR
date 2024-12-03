defmodule CalendriRWeb.EventLive.Index do
  alias CalendriR.Accounts
  use CalendriRWeb, :live_view

  alias CalendriR.Events
  alias CalendriR.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    # Abonnement aux mises à jour des événements
    Phoenix.PubSub.subscribe(CalendriR.PubSub, "events_updates")

    user_id = socket.assigns.current_user.id
    events = Events.list_events_for_user(user_id)
    {:ok, stream(socket, :events, events)}
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Events.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end

  @impl true
  def handle_event("subscribe", %{"event_id" => event_id}, socket) do
    user_id = socket.assigns.current_user.id

    case Accounts.subscribe_to_event(user_id, String.to_integer(event_id)) do
      {:ok, _user} ->
        {:noreply, put_flash(socket, :info, "Subscribed to event successfully")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to subscribe to event")}
    end
  end
  @impl true
  def handle_event("unsubscribe", %{"event_id" => event_id}, socket) do
    case Accounts.unsubscribe_from_event(socket.assigns.current_user.id, event_id) do
      {:ok, _message} ->
        # Mettre à jour l'état de l'utilisateur
        user_is_subscribed = false
        {:noreply, assign(socket, user_is_subscribed: user_is_subscribed)}

      {:error, _message} ->
        # Gérer l'erreur (affichage d'un message d'erreur, etc.)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:update_events, socket) do
    # Récupérer la liste des événements après une mise à jour
    user_id = socket.assigns.current_user.id
    updated_events = Events.list_events_for_user(user_id)

    # Rafraîchir les événements dans la vue
    {:noreply, stream(socket, :events, updated_events)}
  end


  @impl true
  def handle_info({CalendriRWeb.EventLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end


end
