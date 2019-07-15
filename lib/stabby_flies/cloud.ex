defmodule StabbyFlies.Cloud do
  use GenServer

  defmodule State do
    @derive Jason.Encoder
    defstruct ~w|id x y speed hp max_hp|a
  end

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %State{
        id: StabbyFlies.SocketIdGen.generate(),
        x: start_x(),
        y: start_y(),
        speed: 5,
        hp: 10,
        max_hp: 10
      }
      #   name: via_tuple(socket_id)
    )
  end

  defp start_x do
    Enum.random(0..3000)
  end

  defp start_y do
    Enum.random(0..150) - 100
  end
end
