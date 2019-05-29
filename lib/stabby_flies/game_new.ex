defmodule StabbyFlies.GameNew do
  """
  Interface between the world and the game
  """

  alias StabbyFlies.PlayerSupervisor

  # Join Lobby

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

  def move(player_name) do
  end

  # Move

  # Update 
  ### Note: Move to PubSub but for now keep here
end
