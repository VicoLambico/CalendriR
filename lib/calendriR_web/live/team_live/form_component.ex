defmodule CalendriRWeb.TeamLive.FormComponent do
  use CalendriRWeb, :live_component
  alias CalendriR.Teams

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage team records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="team-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />


        <.input field={@form[:description]} type="text" label="Description" />

        <div>
          <label for="user_ids">Select Users</label>
          <select id="user_ids" name="team[user_ids][]" multiple>
            <%= for user <- @users do %>
                <option value={user.id}><%= user.username %></option>
            <% end %>
          </select>
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Team</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  #TODO: quand current_user créer une team, isAdmin=true
  #TODO: possiblité de chosir d'autre isAdmin=true
  #TODO: lorsque de l'édition, pouvoir ajouter/enlever des user in team

  @impl true
  def update(%{team: team} = assigns, socket) do
    #TODO: UTILISER  list_friend()   pour + de cohérence si l'app devait être déployer
    users = CalendriR.Accounts.list_users()
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:users, users)
     |> assign_new(:form, fn -> to_form(Teams.change_team(team)) end)}
  end

  @impl true
  def handle_event("validate", %{"team" => team_params}, socket) do
    changeset = Teams.change_team(socket.assigns.team, team_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    save_team(socket, socket.assigns.action, team_params)
  end



  defp save_team(socket, :edit, team_params) do
    case Teams.update_team(socket.assigns.team, team_params) do
      {:ok, team} ->
        notify_parent({:saved, team})

        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_team(socket, :new, team_params) do
    case Teams.create_team(team_params) do
      {:ok, team} ->
        user_ids = team_params["user_ids"] || []
        Teams.add_users_to_team(team.id, user_ids)

        notify_parent({:saved, team})

        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
