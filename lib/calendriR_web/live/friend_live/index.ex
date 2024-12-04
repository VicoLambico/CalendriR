defmodule CalendriRWeb.FriendLive.Index do
  use CalendriRWeb, :live_view
  alias CalendriR.Accounts

 # Montre les données initiales à l'ouverture de la page
 @impl true
def mount(_params, session, socket) do
  current_user = Accounts.get_user_by_session_token(session["user_token"])

  if current_user do
    if connected?(socket), do: Phoenix.PubSub.subscribe(CalendriR.PubSub, "friendship_updates:#{current_user.id}")

    users = Accounts.list_users()
            |> Enum.reject(&(&1.id == current_user.id))
            |> Enum.reject(&(Accounts.is_friend?(current_user.id, &1.id)))

    friend_requests = Accounts.list_incoming_friend_requests(current_user.id)
    friends = Accounts.list_friends(current_user.id)
    pending_requests = CalendriR.Accounts.list_pending_requests(current_user.id)

    {:ok, assign(socket,
                 current_user: current_user,
                 users: users,
                 pending_requests: pending_requests,
                 friend_requests: friend_requests,
                 friends: friends)}
  else
    {:error, :unauthorized}
  end
end

@impl true
def handle_info(:update_friendship, socket) do
  current_user = socket.assigns.current_user

  # Recharger les données
  users = Accounts.list_users()
          |> Enum.reject(&(&1.id == current_user.id))
          |> Enum.reject(&(Accounts.is_friend?(current_user.id, &1.id)))

  friend_requests = Accounts.list_incoming_friend_requests(current_user.id)
  friends = Accounts.list_friends(current_user.id)
  pending_requests = CalendriR.Accounts.list_pending_requests(socket.assigns.current_user.id)

  {:noreply, assign(socket, users: users, friend_requests: friend_requests, friends: friends, pending_requests: pending_requests)}
end



 @impl true
 def handle_event("add_friend", %{"friend_id" => friend_id}, socket) do
   case Accounts.request_friendship(socket.assigns.current_user.id, String.to_integer(friend_id)) do
     {:ok, _friendship} ->
       {:noreply, put_flash(socket, :info, "Friend request sent!")}
     {:error, _changeset} ->
       {:noreply, put_flash(socket, :error, "Unable to send friend request.")}
   end
 end



 @impl true
  def handle_event("respond_to_request", params = %{"friend_id" => friend_id, "action" => action}, socket) do
    IO.inspect(params, label: "Params received in handle_event")
    friend_id = String.to_integer(friend_id)  # Assurez-vous que friend_id est un integer

    case Accounts.respond_to_friend_request(socket.assigns.current_user.id, friend_id, action) do

      {:ok, _friendship} ->
        # Recharge les demandes d'amis après réponse
        friend_requests = Accounts.list_incoming_friend_requests(socket.assigns.current_user.id)
        {:noreply,
         put_flash(socket, :info, "Friend request #{action}ed.")
         |> assign(:friend_requests, friend_requests)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Unable to process request.")}
    end
  end

  @impl true
  def handle_event("remove_friend", %{"friend_id" => friend_id}, socket) do
    # Convertir l'ID de l'ami en entier
    friend_id = String.to_integer(friend_id)

    case Accounts.remove_friend(socket.assigns.current_user.id, friend_id) do
      :ok ->
        # Recharge la liste des amis après suppression
        friends = Accounts.list_friends(socket.assigns.current_user.id)
        {:noreply, assign(socket, :friends, friends) |> put_flash(:info, "Friend removed!")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Unable to remove friend.")}
    end
  end

  @impl true
  def handle_event("cancel_request", %{"friend_id" => friend_id}, socket) do
    current_user_id = socket.assigns.current_user.id

    case Accounts.cancel_friend_request(current_user_id, String.to_integer(friend_id)) do
      {:ok, :deleted} ->
        {:noreply, assign(socket, :info, "Friend request canceled.")}

      {:error, :not_found} ->
        {:noreply, assign(socket, :error, "Friend request not found.")}
    end
  end


end
