defmodule CalendriRWeb.UserLoginLive do
  use CalendriRWeb, :live_view


  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center">
      <div class="max-w-md w-full space-y-8 bg-white p-6 rounded-lg shadow-md">
        <.header class="text-center">
          <h2 class="text-3xl font-extrabold text-gray-900">Log in to your account</h2>
          <:subtitle>
            <p class="mt-2 text-sm text-gray-600">
              Don't have an account?
              <.link navigate={~p"/users/register"} class="font-medium text-indigo-600 hover:text-indigo-500">
                Sign up
              </.link>
              for an account now.
            </p>
          </:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="login_form"
          action={~p"/users/log_in"}
          phx-update="ignore"
          class="space-y-6"
        >
          <div class="space-y-4">
            <.input
              field={@form[:email_or_username]}
              type="text"
              label="Email or Username"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>

          <!-- Actions Section -->
          <div class="flex items-center justify-between">
            <label class="flex items-center text-sm text-gray-600">
              <.input field={@form[:remember_me]} type="checkbox" class="mr-2" />
              Keep me logged in
            </label>
            <.link href={~p"/users/reset_password"} class="text-sm font-medium text-indigo-600 hover:text-indigo-500">
              Forgot your password?
            </.link>
          </div>

          <!-- Submit Button -->
          <div class="mt-6">
            <.button
              phx-disable-with="Logging in..."
              class="w-full py-2 px-4 bg-indigo-600 text-white font-semibold rounded-lg hover:bg-indigo-700 hover:scale-105 transform transition-transform duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Log in <span aria-hidden="true">→</span>
            </.button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
