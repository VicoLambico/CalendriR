defmodule CalendriRWeb.PageController do
  use CalendriRWeb, :controller

  @doc"""
  def index(conn, _params) do
    render(conn,"index.html")
  end
  """

  def home(conn, _params) do
    # Vérifier si l'utilisateur est connecté
    if conn.assigns[:current_user] do
      # Rediriger vers /dashboard si l'utilisateur est connecté
      redirect(conn, to: ~p"/dashboard")
    else
      # Afficher la page d'accueil pour les utilisateurs non connectés
      render(conn, :home, layout: false)
    end
  end
end
