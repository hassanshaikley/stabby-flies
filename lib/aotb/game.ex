defmodule Aotb.Game do
  require Logger
  use Agent


  @background [
    ["1", "~", "~", "~"],
    ["~", "~", "~", "~"]
  ]

  def background do
    @background
  end

  def start_link(_) do
    Agent.start_link(fn -> %{ "players": [] } end, name: __MODULE__)
    {:ok, _} = :timer.apply_interval(100, __MODULE__, :loop, []) 
  end

  def loop do
    players = get_players

    Enum.each players, fn player -> 

      if player[:moving][:left] do
        move_player_by_socket_id(player[:socket_id], "left")
      end
      if player[:moving][:right] do
        move_player_by_socket_id(player[:socket_id], "right")
      end
      if player[:moving][:up] do
        move_player_by_socket_id(player[:socket_id], "up")
      end
      if player[:moving][:down] do
        move_player_by_socket_id(player[:socket_id], "down")
      end

      # if (player[:moving][:down] or player[:moving][:left] or player[:moving][:right]  or player[:moving][:up] ) do
        AotbWeb.Endpoint.broadcast("room:game", "update_player", player)
      # end
    end
  end

  def set_player_moving(id, direction, moving) do
    Logger.debug("Player moving")
    player = get_player_by_socket_id(id)
    IO.inspect player
    Agent.update(__MODULE__, fn(state) ->
      updated_player = put_in(player[:moving][direction], moving)
      removed_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | removed_player] )
    end)
  end

  def rotate_player_sword(id, amount) do
    Logger.debug "Rotating Sword #{id} #{amount}"
    player = get_player_by_socket_id(id)
    Agent.update(__MODULE__, fn(state) ->
      current_rotation = player[:sword_rotation]
      Logger.debug current_rotation
      updated_player = put_in(player[:sword_rotation], current_rotation + amount)
      IO.inspect updated_player
      removed_player = List.delete(state.players, player)
      Map.put(state, :players, [updated_player | removed_player] )
    end)
    player
  end

  def add_player(name, socket_id) do
    # x = Enum.random(0..3000)
    x = 100
    y = 150
    player = %{
      name: name,
      x: x, 
      y: y, 
      socket_id: socket_id, 
      moving: %{left: false, up: false, down: false, right: false},
      sword_rotation: 0,
      hp: 10
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

  def move_player_by_socket_id(socket_id, direction) do
    player = get_player_by_socket_id(socket_id)

    speed = 20
    
    Agent.update(__MODULE__, fn(state) ->
      updated_player = case direction do
        "left" -> %{player | x: update_x(player.x, -speed)}
        "right" -> %{player | x: update_x(player.x, speed)}
        "up" -> %{player | y: update_y(player.y, -speed)}
        "down" -> %{player | y: update_y(player.y, speed)}
      end

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

  def calculate_stab_hits(id) do 
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

        # %{
        #   player: other_player, 
        #   hit: rectangles_overlap(stab_data, %{x: x, y: y, width: width, height: height})
        # }
        rectangles_overlap(stab_data, %{x: x, y: y, width: width, height: height})
      end)
    
    # %{x: x, y: y, width: width, height: height, shape: "rectangle"}
    ret
  end

  def player_says_stab_hit(id, hit_id) do
    
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

#     if ():
#     Intersection = Empty
# else:
#     Intersection = Not Empty

  end
end