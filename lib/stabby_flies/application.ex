defmodule StabbyFlies.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      StabbyFlies.Repo,
      StabbyFliesWeb.Endpoint,
      {Registry, [keys: :unique, name: Registry.PlayersServer]},
      {StabbyFlies.PlayerSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: StabbyFlies.Supervisor]
    Supervisor.start_link(children, opts)
    StabbyFlies.Game.start_link(1)
    StabbyFlies.GameNew.loop()
    StabbyFlies.SocketIdGen.start_link()
  end

  def config_change(changed, _new, removed) do
    StabbyFliesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
