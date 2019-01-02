defmodule StabbyFlies.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      StabbyFlies.Repo,
      # Start the endpoint when the application starts
      StabbyFliesWeb.Endpoint
      # Starts a worker by calling: StabbyFlies.Worker.start_link(arg)
      # {StabbyFlies.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StabbyFlies.Supervisor]
    Supervisor.start_link(children, opts)
    StabbyFlies.Game.start_link(1)
    StabbyFlies.SocketIdGen.start_link
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StabbyFliesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
