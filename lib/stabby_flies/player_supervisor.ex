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

  def find_player_pid(name) do
    index =
      players
      |> Enum.find_index(fn player ->
        player.name == name
      end)

    Enum.at(player_pids, index)
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
    pid = find_player_pid(name)
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

  def update_players do
    player_pids
    |> Enum.each(fn player ->
      player = Player.update(player)
      StabbyFliesWeb.Endpoint.broadcast("room:game", "update_player", player)
    end)
  end

  def attempt_stab(player) do
    player_pid = find_player_pid(player)
    can_stab = Player.can_stab(player_pid)

    case(can_stab) do
      true -> {player_stabs(player), []}
      false -> {false, []}
    end
  end

  defp player_stabs(player) do
    player = player_state(player)

    damage = player.damage
    player_x = player.x + 20
    player_y = player.y
    player_width = 50
    sword_hitbox_x = player_x + :math.sin(player.sword_rotation) * 50 - player_width + 10
    sword_hitbox_x_second = player_x + :math.sin(player.sword_rotation) * 20 - player_width + 10
    sword_hitbox_y = player_y - :math.cos(player.sword_rotation) * 55
    sword_hitbox_y_second = player_y - :math.cos(player.sword_rotation) * 15

    sword_hitbox_width = 10
    sword_hitbox_height = 10

    stab_data_first = %{
      x: sword_hitbox_x,
      y: sword_hitbox_y,
      width: sword_hitbox_width,
      height: sword_hitbox_height
    }

    stab_data_second = %{
      x: sword_hitbox_x_second,
      y: sword_hitbox_y_second,
      width: sword_hitbox_width,
      height: sword_hitbox_height
    }

    hit_players =
      players()
      |> Enum.filter(fn x -> x.socket_id != player.socket_id end)
      |> Enum.filter(fn other_player ->
        x = other_player.x - 40
        y = other_player.y - 30

        player_hitbox_width = 80
        player_hitbox_height = 60

        player_hitbox = %{x: x, y: y, width: player_hitbox_width, height: player_hitbox_height}

        is_hit =
          rectangles_overlap(stab_data_first, player_hitbox) ||
            rectangles_overlap(stab_data_second, player_hitbox)

        if is_hit, do: Player.take_damage(find_player_pid(other_player.name), damage), else: 0

        is_hit
      end)

    this_players_pid = find_player_pid(player.name)
    Player.reset_stab_cooldown(this_players_pid)
    # update_last_stab_and_kill_count(player, hit_players, damage)
    # {hit_players, stab_data_second}
    true
  end

  defp rectangles_overlap(rect1, rect2) do
    x1 = rect1.x
    x2 = rect2.x

    y1 = rect1.y
    y2 = rect2.y

    w1 = rect1.width
    w2 = rect2.width

    h1 = rect1.height
    h2 = rect2.height
    !(x1 + w1 < x2 or x2 + w2 < x1 or y1 + h1 < y2 or y2 + h2 < y1)
  end
end
