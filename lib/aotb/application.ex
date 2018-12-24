defmodule Aotb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Aotb.Repo,
      # Start the endpoint when the application starts
      AotbWeb.Endpoint
      # Starts a worker by calling: Aotb.Worker.start_link(arg)
      # {Aotb.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aotb.Supervisor]
    Supervisor.start_link(children, opts)
    Aotb.Game.start_link(1)
    Aotb.SocketIdGen.start_link
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AotbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
