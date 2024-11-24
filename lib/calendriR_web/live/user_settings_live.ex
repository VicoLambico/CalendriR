defmodule CalendriRWeb.UserSettingsLive do
  use CalendriRWeb, :live_view

  alias CalendriR.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center mb-8">
      <h1 class="text-3xl font-extrabold text-gray-800">Account Settings</h1>
      <p class="text-lg text-gray-600 mt-2">Manage your account email address and password settings</p>
    </.header>

    <div class="space-y-12 divide-y divide-gray-200">
      <!-- Change Email Section -->
      <div class="py-6 px-4 bg-white shadow-xl rounded-lg max-w-3xl mx-auto">
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">Change Email Address</h2>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
          class="space-y-6"
        >
          <div class="flex flex-col space-y-4">
            <div class="relative">
              <.input
                field={@email_form[:email]}
                type="email"
                label="Email"
                required
                class="peer p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 transition-all"
              />
              <div class="absolute top-1 left-3 text-gray-500 peer-placeholder-shown:text-sm peer-placeholder-shown:text-gray-500">
                <i class="fas fa-envelope"></i>
              </div>
            </div>

            <div class="relative">
              <.input
                field={@email_form[:current_password]}
                name="current_password"
                id="current_password_for_email"
                type="password"
                label="Current password"
                value={@email_form_current_password}
                required
                class="peer p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 transition-all"
              />
              <div class="absolute top-1 left-3 text-gray-500 peer-placeholder-shown:text-sm peer-placeholder-shown:text-gray-500">
                <i class="fas fa-lock"></i>
              </div>
            </div>
          </div>

          <:actions>
            <.button phx-disable-with="Changing..." class="w-full py-3 mt-4 bg-indigo-600 text-white rounded-lg shadow-lg hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500 transition-all">
              Change Email
            </.button>
          </:actions>
        </.simple_form>
      </div>

      <!-- Change Password Section -->
      <div class="py-6 px-4 bg-white shadow-xl rounded-lg max-w-3xl mx-auto mt-6">
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">Change Password</h2>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
          class="space-y-6"
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <div class="flex flex-col space-y-4">
            <div class="relative">
              <.input
                field={@password_form[:password]}
                type="password"
                label="New password"
                required
                class="peer p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 transition-all"
              />
              <div class="absolute top-1 left-3 text-gray-500 peer-placeholder-shown:text-sm peer-placeholder-shown:text-gray-500">
                <i class="fas fa-key"></i>
              </div>
            </div>

            <div class="relative">
              <.input
                field={@password_form[:password_confirmation]}
                type="password"
                label="Confirm new password"
                class="peer p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 transition-all"
              />
              <div class="absolute top-1 left-3 text-gray-500 peer-placeholder-shown:text-sm peer-placeholder-shown:text-gray-500">
                <i class="fas fa-key"></i>
              </div>
            </div>

            <div class="relative">
              <.input
                field={@password_form[:current_password]}
                name="current_password"
                type="password"
                label="Current password"
                id="current_password_for_password"
                value={@current_password}
                required
                class="peer p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 transition-all"
              />
              <div class="absolute top-1 left-3 text-gray-500 peer-placeholder-shown:text-sm peer-placeholder-shown:text-gray-500">
                <i class="fas fa-lock"></i>
              </div>
            </div>
          </div>

          <:actions>
            <.button phx-disable-with="Changing..." class="w-full py-3 mt-4 bg-indigo-600 text-white rounded-lg shadow-lg hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500 transition-all">
              Change Password
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end



  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
