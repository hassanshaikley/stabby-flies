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

      if (player[:moving][:down] or player[:moving][:left] or player[:moving][:right]  or player[:moving][:up] ) do
        AotbWeb.Endpoint.broadcast("room:game", "update_player", player)
      end

    end

    # Enum.each players, fn player -> 
      # updated_player = case player[:moving][:left] do
      #   true -> %{player | x: update_x(player.x, -speed)
      #   false -> player
      # end
    #   updated_player = case player[:moving][:right] do
    #     true -> %{player | x: update_x(player.x, speed)}
    #     false -> player
    #   end

    #   Agent.update(__MODULE__, fn(state) ->

  
    #     removed_player = List.delete(state.players, player)
    #     Map.put(state, :players, [updated_player | removed_player] )
    #   end)


      # updated_player = case direction do
      #   "left" -> }
      #   "right" ->
      #   "up" -> %{player | y: update_y(player.y, -speed)}
      #   "down" -> %{player | y: update_y(player.y, speed)}
      # end
    # end
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

  # def move_player(name, direction) do
  #   Agent.update(__MODULE__, fn(state) -> 
  #     player = get_player_by_name(name)

  #     Map.replace(state, player, count + 1)
  #   end)
  # end


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

  def remove_player_by_socket_id(socket_id) do
    player = get_player_by_socket_id(socket_id)
    Logger.debug "removing player"
    Agent.update(__MODULE__, fn(state) -> 
      removed_player = List.delete(state.players, player) 
      Map.put(state, :players, removed_player )
    end)
  end


  def watch(player) do
    Agent.update(__MODULE__, fn(state) -> 
      count = Map.get(state, player)
      Map.replace(state, player, count + 1)
    end)
  end

  def player_says_stab_hit(id, hit_id) do
    
  end
end