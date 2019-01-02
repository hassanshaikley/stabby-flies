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

  # def handle_in("fly-rotate", payload, socket) do
  #   player = Game.rotate_player_sword(socket.id, payload["amount"])
  #   # broadcast socket, "fly-rotate", %{id: socket.id, currentRotation: player[:sword_rotation] + payload["amount"]}
  #   {:noreply, socket}
  # end

  def handle_in("stab", payload, socket) do
    damage = 2

    {player, can_stab} = Game.player_can_stab(socket.id)
    Logger.debug "can stab? #{can_stab}"

    if can_stab do
      hit_players = Game.calculate_stab_hits(player, damage)
        
      hit_players_data = hit_players
      |> Enum.map(fn player -> 
        %{
          id: player.socket_id,
          damage: damage
        }
        end
        )
  
      broadcast socket, "stab", %{id: socket.id, hit_players_data: hit_players_data}
      
    end


    {:noreply, socket}
  end

  def handle_in("connect", payload, socket) do
    Logger.debug "Connect"
    {:noreply, socket}
  end

  def handle_in("move", payload, socket) do
    player = Game.set_player_moving(socket.id, String.to_atom(payload["direction"]), payload["down"])
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    Logger.debug("#{@name} > leave #{inspect(reason)}")
    broadcast socket, "disconnect", %{id: socket.id}
    Game.remove_player_by_socket_id(socket.id)
  end


  def handle_info(:after_join, socket) do
    name = ["Bandit", "Neutral", "CrayolaFriendship", "BurgerDude", "Bandicoot", "CalgaryFlames", "CalgaryFlamesDestroyer", "MyMathTeacherWasRight", "Cat", "Aardvark", "Sheep", "FarmHand", "AcidicMilkHotel"] |> Enum.shuffle |> hd
    IO.puts "After Join! Adding Player #{socket.id}"
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
