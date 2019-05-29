defmodule StabbyFlies.PlayerSupervisor do
  use DynamicSupervisor
  alias StabbyFlies.Player

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def player_pids do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {:undefined, pid, :worker, _module} ->
      pid
    end)
  end

  def players do
    player_pids
    |> Enum.map(fn pid ->
      Player.state(pid)
    end)
  end

  def player_state(name) do
    players
    |> Enum.find(fn player ->
      player.name == name
    end)
  end

  def create_player(player_options) do
    spec = Player.child_spec(player_options)

    with {:ok, _} <- DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, player_options[:name]}
    else
      {:error, {:already_started, pid}} ->
        {:error, "player #{player_options[:name]} already exists}"}

      {:error, {%ArgumentError{message: error_message}}} ->
        {:error, error_message}
    end
  end

  def delete_player(name) do
    index =
      players
      |> Enum.find_index(fn player ->
        player.name == name
      end)

    pid = Enum.at(player_pids, index)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def reset do
    player_pids
    |> Enum.map(fn pid ->
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end)
  end

  def update_moving(name, moving) do
    index =
      players
      |> Enum.find_index(fn player ->
        player.name == name
      end)

    pid = Enum.at(player_pids, index)

    Player.update_moving(pid, moving)
  end
end
