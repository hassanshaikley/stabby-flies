defmodule StabbyFlies.GameNew do
  """
  Interface between the controller and the game
  """

  alias StabbyFlies.{PlayerSupervisor, Player}

  def loop do
    IO.puts("Loop")

    get_players
    |> Enum.each(fn player ->
      player = Player.update(player)
      IO.inspect(player, label: :update_player)
      StabbyFliesWeb.Endpoint.broadcast("room:game", "update_player", player)
    end)

    :timer.apply_after(50, __MODULE__, :loop, [])
  end

  def join_lobby(id) do
    IO.puts("Socket #{id} Joined Lobby")
  end

  def join_game(id) do
    IO.puts("Socket #{id} Joined Game")

    PlayerSupervisor.create_player(name: id)
  end

  def get_players do
    PlayerSupervisor.players()
  end

  def leave_game(id) do
    IO.puts("Socket #{id} Left Game")
    PlayerSupervisor.delete_player(id)
  end

  def stab(id) do
    IO.puts("Socket #{id} Stabbing (Unimplemented)")
  end

  def set_player_moving(id, moving) do
    IO.puts("Socket #{id} Moving:")

    PlayerSupervisor.update_moving(id, moving)
  end

  def player_state(id) do
    PlayerSupervisor.player_state(id)
  end
end
