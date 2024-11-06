defmodule CalendriR.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CalendriRWeb.Telemetry,
      CalendriR.Repo,
      {DNSCluster, query: Application.get_env(:calendriR, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CalendriR.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CalendriR.Finch},
      # Start a worker by calling: CalendriR.Worker.start_link(arg)
      # {CalendriR.Worker, arg},
      # Start to serve requests, typically the last entry
      CalendriRWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CalendriR.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CalendriRWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
