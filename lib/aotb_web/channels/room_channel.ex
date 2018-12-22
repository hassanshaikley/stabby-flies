defmodule AotbWeb.RoomChannel do
  use AotbWeb, :channel
  require Logger

  alias Aotb.Game

  @messages ["You are cool", "You suck"]

  def join("room:game", payload, socket) do
    Logger.debug "Joined Lobby"
    socket = socket 
      |> assign(:message, Enum.random(@messages))
      |> assign(:albums, [])
      send(self(), :after_join)
      {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:game).
  def handle_in("shout", payload, socket) do
    # Disabled until input is sanitized
    # Aotb.Message.changeset(%Aotb.Message{}, payload) |> Aotb.Repo.insert  
    # broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("fly-rotate", payload, socket) do
    Game.rotate_player_sword(socket.id, payload["amount"])
    broadcast socket, "fly-rotate", %{id: socket.id}
    {:noreply, socket}
  end

  def handle_in("stab", payload, socket) do
    Logger.debug "Sending down stab"
    broadcast socket, "stab", %{id: socket.id}

    {:noreply, socket}
  end


  def handle_in("connect", payload, socket) do
    Logger.debug "Connect"
    {:noreply, socket}
  end

  # def handle_in("explosion", payload, socket) do
  #   Logger.debug "Explosion"
  #   IO.inspect payload["position"]
  #   broadcast socket, "explosion", %{x: payload["position"]["x"], y: payload["position"]["y"]}

  #   {:noreply, socket}
  # end


  def handle_in("move", payload, socket) do
    Logger.debug("--in move--")
    IO.inspect(payload)
    player = Game.set_player_moving(socket.id, String.to_atom(payload["direction"]), payload["down"])
    IO.inspect(player)
    {:reply, {:ok, payload}, socket}
  end

  def terminate(reason, socket) do
    Logger.debug("#{@name} > leave #{inspect(reason)}")
    broadcast socket, "disconnect", %{id: socket.id}
    Game.remove_player_by_socket_id(socket.id)
  end

  def handle_info(:after_join, socket) do
    name = ["Bessy", "Borkbork", "Borb", "Bob", "Babylon", "Babina", "Bamboon"] |> Enum.shuffle |> hd
    IO.puts "H"
    IO.inspect socket
    new_player = Game.add_player("#{name}-#{socket.id}", socket.id)

    broadcast socket, "connect", %{new_player: new_player, players: Game.get_players,}


    Aotb.Message.get_messages()
    |> Enum.each(fn msg -> push(socket, "shout", %{
        name: msg.name,
        message: msg.message,
      }) end)
      push(socket, "initialize", %{
        new_player: new_player
      })


    {:noreply, socket} # :noreply
  end
end
