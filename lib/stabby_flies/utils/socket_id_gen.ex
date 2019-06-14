# Note: Migrate to PUID later. For now PUID is not being used
# Because the ID is also used for analytics.
defmodule StabbyFlies.SocketIdGen do
  @moduledoc """
  Literally just incrementing a number & Keeping track of a number.

  """
  require Logger

  def start_link do
    Agent.start_link(fn -> %{id: 0} end, name: __MODULE__)
  end

  def generate do
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
