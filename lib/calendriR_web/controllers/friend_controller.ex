defmodule CalendriRWeb.FriendController do
  use CalendriRWeb, :controller
  alias CalendriR.Accounts

  # Demande d'amitié
  def request(conn, %{"friend_id" => friend_id}) do
    current_user = conn.assigns.current_user
    friend_id = String.to_integer(friend_id)

    # Vérifie qu'on ne demande pas à être ami avec soi-même
    if current_user.id == friend_id do
      conn
      |> put_flash(:error, "You cannot send a friend request to yourself.")
     # |> redirect(to: Routes.user_path(conn, :index))
    else
      case Accounts.request_friendship(current_user.id, friend_id) do
        {:ok, _friendship} ->
          conn
          |> put_flash(:info, "Friend request sent.")
        #  |> redirect(to: Routes.user_path(conn, :index))
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Unable to send friend request.")
        #  |> redirect(to: Routes.user_path(conn, :index))
      end
    end
  end

  # Réponse à une demande d'amitié (accepter ou refuser)
  def respond(conn, %{"friend_id" => friend_id, "action" => action}) do
    current_user = conn.assigns.current_user
    friend_id = String.to_integer(friend_id)

    # Vérifie que l'action est valide (acceptation ou refus)
    if action not in ["accept", "decline"] do
      conn
      |> put_flash(:error, "Invalid action.")
      #|> redirect(to: Routes.user_path(conn, :index))
    else
      case Accounts.respond_to_friend_request(current_user.id, friend_id, action) do
        :ok ->
          conn
          |> put_flash(:info, "Friend request #{action}d.")
         # |> redirect(to: Routes.user_path(conn, :index))
        {:error, _reason} ->
          conn
          |> put_flash(:error, "Unable to process request.")
        #  |> redirect(to: Routes.user_path(conn, :index))
      end
    end
  end
end
