defmodule Aotb.Game do
  require Logger
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{ "players": [] } end, name: __MODULE__)
    {:ok, _} = :timer.apply_interval(100, __MODULE__, :loop, []) 
  end

  def loop do
    players = get_players
    # Logger.debug "--LOOP-- #{length(players)}"
    players |> Enum.with_index |> Enum.each fn {player, index} -> 
      update_player(player, index)
      # IO.inspect player

      AotbWeb.Endpoint.broadcast("room:game", "update_player", player)
    end
  end

  def respawn_player(player, index) do
    Agent.update(__MODULE__, fn(state) ->
      updated_player = Map.merge(player, %{hp: player.maxHp, y: 150, x: Enum.random(0..3000) })

      removed_player = List.delete_at(state.players, index)
      Map.put(state, :players, [updated_player | removed_player] )
    end)
  end

  def set_player_moving(id, direction, moving) do
    player = get_player_by_socket_id(id)
    Agent.update(__MODULE__, fn(state) ->
      updated_player = put_in(player[:moving][direction], moving)
      removed_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | removed_player] )
    end)
  end

  def rotate_player_sword(id, amount) do
    player = get_player_by_socket_id(id)
    Agent.update(__MODULE__, fn(state) ->
      current_rotation = player[:sword_rotation]
      updated_player = put_in(player[:sword_rotation], current_rotation + amount)
      removed_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | removed_player] )
    end)
    player
  end

  def add_player(name, socket_id) do
    x = Enum.random(0..3000)
    y = 150
    player = %{
      name: name,
      x: x, 
      y: y, 
      socket_id: socket_id, 
      moving: %{left: false, up: false, down: false, right: false},
      sword_rotation: 0,
      hp: 10,
      maxHp: 10,
      last_stab: Time.utc_now
    }

    Agent.update(__MODULE__, fn(state) -> 
      Map.put(state, :players, [player | state.players] )
    end)
    player
  end

  def reset() do
    Agent.update(__MODULE__, fn(_state) -> %{} end)
  end

  def get_players do
    Agent.get(__MODULE__, fn(state) ->
      state.players
    end)
  end

  def get_player_by_name(name) do
    get_players() |> Enum.find([], fn x -> x[:name] == name end )
  end

  def get_player_by_socket_id(socket_id) do
    get_players() |> Enum.find([], fn x -> x[:socket_id] == socket_id end )
  end

  def update_player(player, index) do
    

    if (player.hp <= 0) do
      # Logger.debug "enum loop respawn"
      respawn_player(player, index)
    else
      speed = 20
      

      y_speed_1 = if player[:moving][:up], do: -speed, else: 0
      y_speed_2 = if player[:moving][:down], do: speed, else: 0

      new_y = update_y(player.y, y_speed_1 + y_speed_2)

      x_speed_1 = if player[:moving][:left], do: -speed, else: 0
      x_speed_2 = if player[:moving][:right], do: speed, else: 0

      new_x = update_x(player.x, x_speed_1 + x_speed_2)
  
      if new_x != 0 or new_y != 0 do
        Agent.update(__MODULE__, fn(state) ->
          updated_player =  %{player | x: new_x }
          updated_player =  %{updated_player | y: new_y }
  
          removed_player = List.delete_at(state.players, index)
          Map.put(state, :players, [updated_player | removed_player] )
        end)
      end
    end
  end



  def do_damage_to_player(socket_id, damage) do
    player = get_player_by_socket_id(socket_id)

    Agent.update(__MODULE__, fn(state) ->
      new_hp = player.hp - damage
      new_hp = if new_hp - damage >= 0, do: new_hp, else: 0
      updated_player = %{player | hp: new_hp}
      removed_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | removed_player] )
    end)

  end

  def remove_player_by_socket_id(socket_id) do
    player = get_player_by_socket_id(socket_id)

    Agent.update(__MODULE__, fn(state) ->
      removed_player = List.delete(state.players, player)
      Map.put(state, :players, removed_player )
    end)
  end

  def (id) do
    player = get_player_by_socket_id(id)
    
    # if player, do: do_damage_to_player(other_player.socket_id, damage), else: 0

  end

  def calculate_stab_hits(id, damage) do 
    player = get_player_by_socket_id(id)
    player_x = player.x + 20
    player_y = player.y
    player_width = 50
    hitbox_x = player_x + :math.sin(player.sword_rotation)*50 - player_width + 10
    hitbox_y = player_y - :math.cos(player.sword_rotation)*55 
    # Logger.debug "x: #{hitbox_x}, y: #{hitbox_y}, player_x: #{player.x}, player_y: #{player.y}"

    x = hitbox_x
    y = hitbox_y
    width = 10
    height = 10

    stab_data = %{x: x, y: y, width: width, height: height}

    # Get all the hit players
    ret = get_players() 
    |>  Enum.filter(fn x -> x.socket_id != id end)
    |>  Enum.filter(fn other_player -> 
        x = other_player.x
        y = other_player.y

        x = other_player.x - 40
        y = other_player.y - 30
        width = 80
        height = 60

        is_hit = rectangles_overlap(stab_data, %{x: x, y: y, width: width, height: height})  
        if is_hit, do: do_damage_to_player(other_player.socket_id, damage), else: 0

        is_hit && other_player.hp > 0
      end)
    
    ret
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
    !(x1+w1<x2 or x2+w2<x1 or y1+h1<y2 or y2+h2<y1)
  end

  defp update_x(x, speed) do
    cond do 
      (x + speed) < 0 -> 0
      (x + speed) > 3000 -> 3000
      (true) -> x + speed
    end
  end

  defp update_y(y, speed) do
    cond do 
      (y + speed) < -100 -> -100
      (y + speed) > 270 -> 270
      (true) -> y + speed
    end
  end
end