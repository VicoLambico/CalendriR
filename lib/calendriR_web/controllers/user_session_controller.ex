defmodule CalendriRWeb.UserSessionController do
  use CalendriRWeb, :controller

  alias CalendriR.Accounts
  alias CalendriRWeb.UserAuth

  # Gestion après enregistrement
  def create(conn, %{"_action" => "registered", "user" => user_params}) do
    create_account_with_user_params(conn, user_params, "Account created successfully!")
  end

  # Gestion après la mise à jour du mot de passe
  def create(conn, %{"_action" => "password_updated", "user" => user_params}) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create_with_user_params(user_params, "Password updated successfully!")
  end

  # Connexion standard
  def create(conn, %{"user" => user_params}) do
    create_with_user_params(conn, user_params, "Welcome back!")
  end

  # Déconnexion
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  # Fonctions privées
  defp create_account_with_user_params(conn, %{"email" => email, "password" => password, "username" => _username}, info) do
    handle_user_authentication(conn, email, password, info)
  end

  defp create_with_user_params(conn, %{"email_or_username" => identifier, "password" => password}, info) do
    handle_user_authentication(conn, identifier, password, info)
  end

  defp handle_user_authentication(conn, identifier, password, success_message) do
    if user = Accounts.get_user_by_email_or_username_and_password(identifier, password) do
      conn
      |> put_flash(:info, success_message)
      |> UserAuth.log_in_user(user)
    else
      conn
      |> put_flash(:error, "Invalid email/username, or password")
      |> redirect(to: ~p"/users/log_in")
    end
  end
end
