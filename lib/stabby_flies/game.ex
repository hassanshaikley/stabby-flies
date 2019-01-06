defmodule StabbyFlies.Game do
  @moduledoc """
  This is the Game module.

  All of the game logic is in here including the game loop and the game state
  """
  require Logger
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{players: []} end, name: __MODULE__)
    {:ok, _} = :timer.apply_interval(50, __MODULE__, :game_loop, [])
  end

  def game_loop do
    get_players
    |> Enum.each(fn player ->
      update_player(player)
      StabbyFliesWeb.Endpoint.broadcast("room:game", "update_player", player)
    end)
  end

  def respawn_player(socket_id) do
    Agent.update(__MODULE__, fn state ->
      player = get_player_by_socket_id(socket_id, state.players)

      updated_player =
        Map.merge(player, %{
          hp: player.maxHp,
          y: start_y,
          x: start_x,
          kill_count: 0,
          moving: %{left: false, up: false, down: false, right: false}
        })

      players_excluding_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | players_excluding_player])
    end)
  end

  def set_player_moving(socket_id, direction, moving) do
    Agent.update(__MODULE__, fn state ->
      player = get_player_by_socket_id(socket_id, state.players)

      updated_player = put_in(player[:moving][direction], moving)
      players_excluding_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | players_excluding_player])
    end)
  end

  def add_player(name, socket_id) do
    x = start_x
    y = start_y

    player = %{
      name: name,
      x: x,
      y: y,
      socket_id: socket_id,
      moving: %{left: false, up: false, down: false, right: false},
      sword_rotation: 0,
      hp: 10,
      maxHp: 10,
      last_stab: Time.utc_now(),
      speed: 20 * 10,
      kill_count: 0,
      damage: 5
    }

    Agent.update(__MODULE__, fn state ->
      Map.put(state, :players, [player | state.players])
    end)

    player
  end

  def reset do
    Agent.update(__MODULE__, fn _state -> %{} end)
  end

  def get_players do
    Agent.get(__MODULE__, fn state ->
      state.players
    end)
  end

  def get_player_by_name(name) do
    get_players() |> Enum.find([], fn x -> x[:name] == name end)
  end

  def get_player_by_socket_id(socket_id) do
    get_players() |> Enum.find([], fn x -> x[:socket_id] == socket_id end)
  end

  def get_player_by_socket_id(socket_id, player_list) do
    player_list |> Enum.find([], fn x -> x[:socket_id] == socket_id end)
  end

  def update_player(player) do
    if player.hp <= 0 do
      respawn_player(player.socket_id)
    else
      # this should be proportional to the loop timer
      speed = player.speed / 10

      y_speed_up = if player[:moving][:up], do: -speed, else: 0
      y_speed_down = if player[:moving][:down], do: speed, else: 0

      new_y = update_y(player.y, y_speed_up + y_speed_down)

      x_speed_left = if player[:moving][:left], do: -speed, else: 0
      x_speed_right = if player[:moving][:right], do: speed, else: 0

      new_x = update_x(player.x, x_speed_left + x_speed_right)

      if new_x != 0 or new_y != 0 do
        Agent.update(__MODULE__, fn state ->
          player_now = get_player_by_socket_id(player.socket_id, state.players)
          new_rotation = get_rotation(player_now)

          updated_player = %{player_now | x: new_x}
          updated_player = %{updated_player | y: new_y}
          updated_player = put_in(updated_player[:sword_rotation], new_rotation)
          players_excluding_player = List.delete(state.players, player_now)
          Map.put(state, :players, [updated_player | players_excluding_player])
        end)
      end
    end
  end

  def get_rotation(player) do
    direction = player[:moving]
    correct_left = direction[:left] and !direction[:right]
    correct_right = direction[:right] and !direction[:left]
    correct_up = direction[:up] and !direction[:down]
    correct_down = direction[:down] and !direction[:up]

    # Rotation (in radians) of the sword based off the keys pressed
    correct_direction(%{
      left: correct_left,
      right: correct_right,
      up: correct_up,
      down: correct_down,
      sword_rotation: player[:sword_rotation]
    })
  end

  defp correct_direction(%{left: true, right: false, up: false, down: false, sword_rotation: _sword_rotation}), do: -:math.pi() / 2
  defp correct_direction(%{left: true, right: false, up: true, down: false, sword_rotation: _sword_rotation}), do: -:math.pi() / 3
  defp correct_direction(%{left: true, right: false, up: false, down: true, sword_rotation: _sword_rotation}), do: 3.92699
  defp correct_direction(%{left: false, right: true, up: false, down: false, sword_rotation: _sword_rotation}), do: :math.pi() / 2
  defp correct_direction(%{left: false, right: true, up: true, down: false, sword_rotation: _sword_rotation}), do: :math.pi() / 3
  defp correct_direction(%{left: false, right: true, up: false, down: true, sword_rotation: _sword_rotation}), do: -3.92699
  defp correct_direction(%{left: false, right: false, up: true, down: false, sword_rotation: _sword_rotation}), do: 0
  defp correct_direction(%{left: false, right: false, up: false, down: true, sword_rotation: _sword_rotation}), do: :math.pi()
  defp correct_direction(%{
         left: false,
         right: false,
         up: false,
         down: false,
         sword_rotation: sword_rotation
       }),
       do: sword_rotation
  def do_damage_to_player(socket_id, damage) do
    Agent.update(__MODULE__, fn state ->
      player = get_player_by_socket_id(socket_id, state.players)
      new_hp = if player.hp - damage >= 0, do: player.hp - damage, else: 0
      updated_player = %{player | hp: new_hp}
      players_excluding_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | players_excluding_player])
    end)
  end

  def remove_player_by_socket_id(socket_id) do
    Agent.update(__MODULE__, fn state ->
      player = get_player_by_socket_id(socket_id, state.players)
      players_excluding_player = List.delete(state.players, player)
      Map.put(state, :players, players_excluding_player)
    end)
  end

  @doc """
  Calculates if a player was hit and applies damage

  The hitbox logic is all here, and that invlves some hacks hence the strange math. It's absolute madness but it works!

  Returns `[hit_player, other_hit_player]`.

  ## Examples

      iex> MyApp.Hello.world(:john)
      :ok

  """
  def player_stabs(player) do
    damage = player.damage
    player_x = player.x + 20
    player_y = player.y
    player_width = 50
    sword_hitbox_x = player_x + :math.sin(player.sword_rotation) * 50 - player_width + 10
    sword_hitbox_x_second =  player_x + :math.sin(player.sword_rotation) * 20 - player_width + 10
    sword_hitbox_y = player_y - :math.cos(player.sword_rotation) * 55
    sword_hitbox_y_second = player_y - :math.cos(player.sword_rotation) * 15

    sword_hitbox_width = 10
    sword_hitbox_height = 10

    stab_data_first = %{x: sword_hitbox_x, y: sword_hitbox_y, width: sword_hitbox_width, height: sword_hitbox_height}

    stab_data_second = %{x: sword_hitbox_x_second, y: sword_hitbox_y_second, width: sword_hitbox_width, height: sword_hitbox_height}

    
    hit_players =
      get_players()
      |> Enum.filter(fn x -> x.socket_id != player.socket_id end)
      |> Enum.filter(fn other_player ->
        x = other_player.x - 40
        y = other_player.y - 30

        player_hitbox_width = 80
        player_hitbox_height = 60

        player_hitbox = %{x: x, y: y, width: player_hitbox_width, height: player_hitbox_height}

        is_hit = rectangles_overlap(stab_data_first, player_hitbox) || rectangles_overlap(stab_data_second, player_hitbox)

        if is_hit, do: do_damage_to_player(other_player.socket_id, damage), else: 0
        is_hit
      end)

    update_last_stab_and_kill_count(player, hit_players, damage)
    {hit_players, stab_data_second}
  end

  def update_last_stab_and_kill_count(player, hit_players, damage) do
    killed_players =
      Enum.filter(hit_players, fn hit_player ->
        hit_player.hp - damage <= 0
      end)

    Agent.update(__MODULE__, fn state ->
      player = get_player_by_socket_id(player.socket_id, state.players)
      updated_player = %{player | last_stab: Time.utc_now()}
      updated_player = %{updated_player | kill_count: player.kill_count + length(killed_players)}

      updated_player = if length(killed_players) > 0, do: %{updated_player | hp: updated_player.maxHp}, else: updated_player

      players_excluding_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | players_excluding_player])
    end)
  end

  def player_can_stab(socket_id) do
    player = get_player_by_socket_id(socket_id)

    cooldown = 300
    now = Time.utc_now()

    can_stab = Time.diff(now, player.last_stab, :milliseconds) >= cooldown
    {player, can_stab}
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

  defp update_x(x, speed) do
    cond do
      x + speed < 0 -> 0
      x + speed > 3000 -> 3000
      true -> x + speed
    end
  end

  defp update_y(y, speed) do
    cond do
      y + speed < -100 -> -100
      y + speed > 270 -> 270
      true -> y + speed
    end
  end

  defp update_hp(hp, change, max_hp) do
    cond do
      hp + change <= 0 -> 0
      hp + change >= max_hp -> max_hp
      true -> hp + change
    end
  end

  defp start_y do
    Enum.random(-100..270)
  end

  defp start_x do
    Enum.random(0..3000)
  end
end
