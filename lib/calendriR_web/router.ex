defmodule CalendriRWeb.Router do

  use CalendriRWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CalendriRWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CalendriRWeb do

    pipe_through :browser

    get "/", PageController, :home

     # Ajouter ici les routes
     live "events", EventLive.Index, :index
     live "/events/new", EventLive.Index, :new
     live "/events/:id/edit", EventLive.Index, :edit

     live "/events/:id", EventLive.Show, :show
     live "/events/:id/show/edit", EventLive.Show, :edit




  end

  # Other scopes may use custom stacks.
  # scope "/api", CalendriRWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:calendriR, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CalendriRWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
