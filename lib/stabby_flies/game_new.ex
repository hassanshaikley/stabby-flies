defmodule StabbyFlies.GameNew do
  """
  Interface between the controller and the game
  """

  alias StabbyFlies.{PlayerSupervisor, Player}

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

    Player.update_moving(id, moving)
  end

  def player_state(id) do
    PlayerSupervisor.player_state(id)
  end
end
