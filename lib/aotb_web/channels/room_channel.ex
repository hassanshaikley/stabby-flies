defmodule AotbWeb.RoomChannel do
  use AotbWeb, :channel
  require Logger

  alias Aotb.Game

  @messages ["You are cool", "You suck"]

  def join("room:lobby", payload, socket) do
    socket = socket 
      |> assign(:message, Enum.random(@messages))
      |> assign(:albums, [])
      send(self(), :after_join)
      {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    Aotb.Message.changeset(%Aotb.Message{}, payload) |> Aotb.Repo.insert  
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("connect", payload, socket) do
    {:noreply, socket}
  end

  def handle_in("disconnect", payload, socket) do
    Game.remove_player_by_socket_id(socket.id)
    broadcast socket, "disconnect", %{id: socket.id}

    {:noreply, socket}
  end

  def handle_in("move", payload, socket) do
    player = Game.set_player_moving(socket.id, String.to_atom(payload["direction"]), payload["down"])
    # broadcast socket, "update_player", player

    {:reply, {:ok, payload}, socket}
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



  def handle_in("keydown", payload, socket) do
    Logger.debug "keydown #{payload["key"]}" 

    {:reply, {:ok, payload}, socket}
  end

  def handle_in("diconnect", payload, socket) do
    Logger.debug "DISCONNECT"
    {:noreply, socket}
  end


end
