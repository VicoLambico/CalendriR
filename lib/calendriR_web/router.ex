defmodule CalendriRWeb.Router do

  use CalendriRWeb, :router

  import CalendriRWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CalendriRWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CalendriRWeb do

    pipe_through :browser

    get "/", PageController, :home

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

  ## Authentication routes

  scope "/", CalendriRWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{CalendriRWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", CalendriRWeb do
    pipe_through [:browser, :require_authenticated_user]


    live_session :require_authenticated_user,
      on_mount: [{CalendriRWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email




      live "/dashboard", DashbaordLive.Index, :index



      post "/friends/request/:friend_id", FriendController, :request
      post "/friends/respond/:friend_id/:action", FriendController, :respond



     # Ajouter ici les routes

     live "/friends", FriendLive.Index, :index


     live "/events", EventLive.Index, :index
     live "/events/new", EventLive.Index, :new
     live "/events/:id/edit", EventLive.Index, :edit

     live "/events/:id", EventLive.Show, :show
     live "/events/:id/show/edit", EventLive.Show, :edit

     live "/teams", TeamLive.Index, :index
     live "/teams/new", TeamLive.Index, :new
     live "/teams/:id/edit", TeamLive.Index, :edit

     live "/teams/:id", TeamLive.Show, :show
     live "/teams/:id/show/edit", TeamLive.Show, :edit

    end
  end

  scope "/", CalendriRWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{CalendriRWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
