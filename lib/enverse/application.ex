defmodule Enverse.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EnverseWeb.Telemetry,
      Enverse.Repo,
      {Oban, Application.fetch_env!(:enverse, Oban)},
      {DNSCluster, query: Application.get_env(:enverse, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Enverse.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Enverse.Finch},
      # Start a worker by calling: Enverse.Worker.start_link(arg)
      # {Enverse.Worker, arg},
      # Start to serve requests, typically the last entry
      EnverseWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Enverse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EnverseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
