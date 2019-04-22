defmodule StabbyFlies.PlayerServer do
  use GenServer
  alias StabbyFlies.{Player}

  def start_link(opts) do
    # GenServer.start_link(__MODULE__, :ok, opts)
    IO.inspect(opts, label: "__OPTS__")

    GenServer.start_link(
      __MODULE__,
      %Player{name: "The Name", x: opts[:x], y: opts[:y], hp: opts[:hp], velx: 0, vely: 0},
      opts
    )
  end

  #   def init(:ok) do
  #     {:ok, %{}}
  #   end

  def init(%Player{} = initial_state), do: {:ok, initial_state}

  def handle_call(:status, _from, %Player{} = player) do
    {:reply, player, player}
  end

  def status(pid) do
    GenServer.call(pid, :status)
  end
end
