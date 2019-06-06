defmodule StabbyFlies.Player do
  use GenServer

  defmodule State do
    @derive Jason.Encoder
    defstruct ~w|nickname socket_id name x y moving hp max_hp sword_rotation last_stab_time kill_count speed damage|a
  end

  def start_link(opts) do
    defaults = [
      name: "NAMELESS",
      x: start_x(),
      y: start_y(),
      velx: 0,
      vely: 0,
      hp: 10,
      max_hp: 10,
      sword_rotation: 0,
      nickname: "poggie"
    ]

    init_fly = Keyword.merge(defaults, opts)

    name = Keyword.get(init_fly, :name)
    x = Keyword.get(init_fly, :x)
    y = Keyword.get(init_fly, :y)
    velx = Keyword.get(init_fly, :velx)
    vely = Keyword.get(init_fly, :vely)
    hp = Keyword.get(init_fly, :hp)
    max_hp = Keyword.get(init_fly, :max_hp)
    socket_id = Keyword.get(init_fly, :socket_id)
    nickname = Keyword.get(init_fly, :nickname)

    # sword_rotation = Keyword.get(init_fly, :sword_rotation)

    GenServer.start_link(
      __MODULE__,
      %State{
        name: name,
        x: x,
        y: y,
        hp: hp,
        max_hp: max_hp,
        sword_rotation: 0,
        last_stab_time: Time.add(Time.utc_now(), -1),
        kill_count: 0,
        speed: 20 * 10,
        damage: 5,
        moving: %{
          left: false,
          right: false,
          up: false,
          down: false
        },
        nickname: nickname,
        socket_id: socket_id
      },
      name: via_tuple(socket_id)
    )
  end

  def init(init_arg), do: {:ok, init_arg}
  def state(pid), do: GenServer.call(pid, :state)
  def take_damage(pid, amount), do: GenServer.call(pid, {:take_damage, amount})
  def update_position(pid), do: GenServer.call(pid, :update_position)
  def can_stab(pid), do: GenServer.call(pid, :can_stab)
  def reset_stab_cooldown(pid), do: GenServer.call(pid, :reset_stab_cooldown)
  # def respawn(pid), do: GenServer.call(pid, :respawn)
  def increment_kill_count(pid), do: GenServer.call(pid, :increment_kill_count)
  def update_moving(pid, moving), do: GenServer.call(pid, {:update_moving, moving})

  def update(pid), do: GenServer.call(pid, :update)

  def handle_call(:can_stab, _from, %State{last_stab_time: last_stab_time} = state) do
    stab_cooldown = 250
    now = Time.utc_now()

    can_stab = Time.diff(now, last_stab_time, :millisecond) >= stab_cooldown
    {:reply, can_stab, state}
  end

  def handle_call(:reset_stab_cooldown, _from, state) do
    new_state = Map.merge(state, %{last_stab_time: Time.utc_now()})
    {:reply, new_state, new_state}
  end

  # def handle_call(:respawn, _from, state) do
  #   max_hp = state.max_hp

  #   new_state =
  #     Map.merge(state, %{
  #       hp: max_hp,
  #       x: start_x,
  #       y: start_y,
  #       last_stab_time: Time.add(Time.utc_now(), -1),
  #       kill_count: 0
  #     })

  #   {:reply, new_state, new_state}
  # end

  def handle_call(:increment_kill_count, _from, state) do
    new_state = Map.merge(state, %{kill_count: state.kill_count + 1})
    {:reply, new_state, new_state}
  end

  def handle_call(:state, _from, %State{} = state) do
    {:reply, state, state}
  end

  def handle_call(
        {:take_damage, amount},
        _from,
        %State{hp: hp, max_hp: max_hp} = state
      ) do
    new_hp = if hp - amount < 0, do: 0, else: hp - amount

    case new_hp do
      x when x <= 0 ->
        new_state =
          Map.merge(state, %{
            hp: max_hp,
            x: start_x,
            y: start_y,
            last_stab_time: Time.add(Time.utc_now(), -1),
            kill_count: 0
          })

        StabbyFliesWeb.Endpoint.broadcast("room:game", "respawn", new_state)

        {:reply, true, new_state}

      x ->
        new_state = Map.merge(state, %{hp: new_hp})
        {:reply, false, new_state}
    end
  end

  # def handle_call(
  #       :update_position,
  #       _from,
  #       %State{x: x, y: y, moving: moving, speed: speed} = state
  #     ) do
  #   new_x = if x + velx(moving, speed) < 0, do: 0, else: x + velx(moving, speed)
  #   new_x = if new_x + velx(moving, speed) >= 3000, do: 3000, else: new_x + velx(moving, speed)

  #   new_y = if y + vely(moving, speed) < -100, do: -100, else: y + vely(moving, speed)
  #   new_y = if new_y + vely(moving, speed) >= 270, do: 270, else: new_y + vely(moving, speed)

  #   new_state = Map.merge(state, %{x: new_x, y: new_y})
  #   {:reply, new_state, new_state}
  # end

  def handle_call(
        :update,
        _from,
        %State{x: x, y: y, moving: moving, speed: speed, sword_rotation: sword_rotation} = state
      ) do
    speed = speed / 40
    vel_x_ = velx(moving, speed)
    vel_y_ = vely(moving, speed)

    new_x = if x + vel_x_ < 0, do: 0, else: x + vel_x_
    new_x = if new_x + vel_x_ >= 3000, do: 3000, else: new_x + vel_x_

    new_y = if y + vel_y_ < -100, do: -100, else: y + vel_y_
    new_y = if new_y + vel_y_ >= 270, do: 270, else: new_y + vel_y_

    case vel_x_ == 0 and vel_y_ == 0 do
      false ->
        {:reply,
         Map.merge(state, %{x: new_x, y: new_y, sword_rotation: :math.atan2(vel_x_, -vel_y_)}),
         Map.merge(state, %{x: new_x, y: new_y, sword_rotation: :math.atan2(vel_x_, -vel_y_)})}

      _ ->
        {:reply, Map.merge(state, %{x: new_x, y: new_y, sword_rotation: sword_rotation}),
         Map.merge(state, %{x: new_x, y: new_y, sword_rotation: sword_rotation})}
    end
  end

  def handle_call({:update_moving, moving}, _from, state) do
    # new_rotation = get_rotation(state["moving"])

    new_state = Map.merge(state, %{moving: moving})

    {:reply, new_state, new_state}
  end

  defp start_y do
    Enum.random(-100..270)
  end

  defp start_x do
    Enum.random(0..3000)
  end

  defp velx(moving, speed) do
    new_moving = %{left: moving["left"], right: moving["right"]}

    case new_moving do
      %{left: true, right: true} -> 0
      %{left: true, right: false} -> -speed
      %{left: false, right: true} -> speed
      %{left: false, right: false} -> 0
      _ -> 0
    end
  end

  defp vely(moving, speed) do
    new_moving = %{down: moving["down"], up: moving["up"]}

    case new_moving do
      %{up: true, down: true} -> 0
      %{up: true, down: false} -> -speed
      %{up: false, down: true} -> speed
      %{up: false, down: false} -> 0
      _ -> 0
    end
  end

  defp via_tuple(socket_id) do
    {:via, Registry, {Registry.PlayersServer, socket_id}}
  end
end
