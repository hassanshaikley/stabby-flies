defmodule StabbyFliesWeb.GameChannel do
  @moduledoc """
  Description about the use of this Module
  """
  use StabbyFliesWeb, :channel
  require Logger

  alias StabbyFlies.{Game, Game, Player, Visitor}

  def handle_in("connect", payload, socket) do
    {:noreply, socket}
  end

  def join("game", payload, socket) do
    Logger.debug("Joined Lobby #{payload["nickname"]}")

    socket =
      socket
      |> assign(:nickname, payload["nickname"])

    StabbyFlies.Repo.insert(%Visitor{
      ip_address: "Unknown",
      nickname: payload["nickname"] |> String.slice(0, 40)
    })

    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("shout", payload, socket) do
    # Disabled until input is sanitized
    StabbyFlies.Message.changeset(%StabbyFlies.Message{}, payload) |> StabbyFlies.Repo.insert()
    response = payload |> Map.put(:socket_id, socket.id)
    broadcast(socket, "shout", response)
    {:noreply, socket}
  end

  def handle_in("move", %{"moving" => moving}, socket) do
    Game.set_player_moving(socket.id, moving)

    {:noreply, socket}
  end

  def handle_in("move", _, socket) do
    {:noreply, socket}
  end

  def handle_in("stab", payload, socket) do
    {stabbed?, hit_players} = Game.player_stabs(socket.id)

    if stabbed? == true,
      do:
        broadcast(socket, "stab", %{
          socket_id: socket.id,
          hit_players_data: hit_players
        })

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.puts("PLAYER TERMINATED")
    Game.leave_game(socket.id)
    broadcast(socket, "disconnect", %{socket_id: socket.id})
  end

  def handle_info(:after_join, socket) do
    Game.join_game(socket.id, socket.assigns.nickname)
    new_player = Game.player_state(socket.id)
    # name = elem(eh, 1)

    # new_player = Game.add_player("#{socket.assigns.nickname}", socket.id)

    broadcast(socket, "connect", %{new_player: new_player, players: Game.get_players()})

    push(socket, "initialize", %{
      new_player: new_player
    })

    # Disabled for now
    # StabbyFlies.Message.get_messages()
    # |> Enum.each(fn msg -> push(socket, "shout", %{
    #     name: msg.name,
    #     message: msg.message,
    #   }) end)
    {:noreply, socket}
  end
end
