defmodule CalendriRWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.
  """
  use CalendriRWeb, :html

  embed_templates "layouts/*"

  def render_account_menu(assigns) do
    ~H"""
    <div class="account-menu">

      <div class="account-menu-content">
        <ul>
            <li>
          <%= @current_user.username %>
          </li>
          <li>
            <.link href={~p"/users/settings"} class="text-black">Settings</.link>
          </li>
          <li>
            <.link href={~p"/users/log_out"} method="delete" class="text-black">Log out</.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end




  def render_menu(assigns) do
    ~H"""
    <div class="menu-left">

      <div class="menu-content">
        <ul>
          <li><.link href={~p"/dashboard"} class="text-black">Home</.link></li>
          <li><.link href={~p"/teams"} class="text-black">Teams</.link></li>
          <li><.link href={~p"/events"} class="text-black">Events</.link></li>
        </ul>
      </div>
    </div>
    """
  end

end
