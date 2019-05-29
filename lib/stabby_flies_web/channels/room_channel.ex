defmodule StabbyFliesWeb.RoomChannel do
  @moduledoc """
  Description about the use of this Module
  """
  use StabbyFliesWeb, :channel
  require Logger

  alias StabbyFlies.{Game, GameNew, Player}

  def handle_in("connect", payload, socket) do
    {:noreply, socket}
  end

  def join("room:game", payload, socket) do
    unique_id = "Fly-#{socket.id}"

    Logger.debug("Joined Lobby #{payload["nickname"]}")

    socket =
      socket
      |> assign(:unique_id, unique_id)
      |> assign(:nickname, payload["nickname"])

    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("shout", payload, socket) do
    # Disabled until input is sanitized
    # StabbyFlies.Message.changeset(%StabbyFlies.Message{}, payload) |> StabbyFlies.Repo.insert
    # broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("move", %{"moving" => moving}, socket) do
    GameNew.set_player_moving(socket.assigns.unique_id, moving)

    {:noreply, socket}
  end

  def handle_in("move", _, socket) do
    {:noreply, socket}
  end

  def handle_in("stab", payload, socket) do
    # {player, can_stab} = Game.player_can_stab(socket.assigns.unique_id)

    # if can_stab do
    #   {hit_players, stab_hitbox} = Game.player_stabs(player)

    #   hit_players_data =
    #     hit_players
    #     |> Enum.map(fn hit_player ->
    #       %{
    #         socket_id: hit_player.socket_id,
    #         damage: player.damage
    #       }
    #     end)

    #   broadcast(socket, "stab", %{
    #     socket_id: socket.id,
    #     hit_players_data: hit_players_data,
    #     stab_hitbox: stab_hitbox
    #   })
    # end

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    GameNew.leave_game(socket.assigns.unique_id)

    # Logger.debug("#{@name} > leave #{inspect(reason)}")
    # broadcast(socket, "disconnect", %{id: socket.id})
    # Game.remove_player_by_socket_id(socket.id)
  end

  def handle_info(:after_join, socket) do
    GameNew.join_game(socket.assigns.unique_id)
    new_player = GameNew.player_state(socket.assigns.unique_id)
    # name = elem(eh, 1)

    # new_player = Game.add_player("#{socket.assigns.nickname}", socket.id)

    broadcast(socket, "connect", %{new_player: new_player, players: GameNew.get_players()})

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
