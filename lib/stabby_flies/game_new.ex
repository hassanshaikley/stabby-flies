defmodule StabbyFlies.GameNew do
  """
  Interface between the controller and the game
  """

  alias StabbyFlies.PlayerSupervisor

  def join_lobby() do
  end

  def join_game(player_name) do
    PlayerSupervisor.create_player(name: player_name)
  end

  def get_players do
    PlayerSupervisor.players()
  end

  def disconnect(player_name) do
    PlayerSupervisor.delete_player(player_name)
  end

  def stab(player_name) do
  end

  def set_player_moving(player_name, moving) do
  end

  # Update 
end
