defmodule StabbyFlies.SocketIdGen do
  require Logger

  def start_link do
    # Agent.stop(__MODULE__)
    Agent.start_link(fn -> %{id: 0} end, name: __MODULE__)
  end

  def gen_id do
    x = Enum.random(0..200)
    id = get_id + 1

    Agent.update(__MODULE__, fn state ->
      Map.put(state, :id, id)
    end)

    id
  end

  def get_id do
    Agent.get(__MODULE__, fn state ->
      state.id
    end)
  end
end
