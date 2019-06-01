defmodule StabbyFlies.Game do
  """
  Interface between the controller and the game
  """

  use GenServer

  alias StabbyFlies.{PlayerSupervisor, Player}

  def start_link(opts) do
    IO.puts("Game.start_link")

    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(opts) do
    loop()
    {:ok, []}
  end

  def loop do
    PlayerSupervisor.update_players()

    :timer.apply_after(25, __MODULE__, :loop, [])
  end

  def join_lobby(id) do
    IO.puts("Socket #{id} Joined Lobby")
  end

  def join_game(id, nickname) do
    IO.puts("Socket #{id} Joined Game")

    PlayerSupervisor.create_player(name: id, socket_id: id, nickname: nickname)
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

  def player_stabs(id) do
    PlayerSupervisor.attempt_stab(id)
  end
end
