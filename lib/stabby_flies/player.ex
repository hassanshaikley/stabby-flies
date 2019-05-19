defmodule StabbyFlies.Player do
  use GenServer

  alias __MODULE__

  defmodule State do
    defstruct ~w|name x y velx vely hp max_hp sword_rotation|a
  end

  # defstruct

  # defguardp is_alive?(hp) when is_integer(hp) and hp > 0

  # def alive?(%{hp: hp}) when is_alive?(hp), do: true
  # def alive?(%{}), do: false

  # def decrease_hp(%{hp: hp} = player, quantity) do
  #   %{player | hp: hp - quantity}
  # end

  # def move_right(%{velx: velx, hp: hp} = player, quantity \\ 1) do
  #   # when is_alive?(hp) do
  #   %{player | velx: quantity}
  # end

  # def move_left(%{velx: velx, hp: hp} = player, quantity \\ 1) do
  #   %{player | velx: -1 * quantity}
  # end

  # def move_up(%{vely: vely, hp: hp} = player, quantity \\ 1) do
  #   %{player | vely: -1 * quantity}
  # end

  # def move_down(%{vely: vely, hp: hp} = player, quantity \\ 1) do
  #   %{player | vely: 1 * quantity}
  # end

  ## ALL NEW SHIT

  # def start_link(opts) do
  #   # GenServer.start_link(__MODULE__, :ok, opts)
  #   IO.inspect(opts, label: "__OPTS__")

  #   GenServer.start_link(
  #     __MODULE__,
  #     %{name: "The Name", x: opts[:x], y: opts[:y], hp: opts[:hp], velx: 0, vely: 0},
  #     opts
  #   )
  # end

  # def init(thin) do
  #   IO.inspect(thin)
  # end

  def start_link(opts) do
    defaults = [
      name: "NAMELESS",
      x: 0,
      y: 0,
      velx: 0,
      vely: 0,
      hp: 1,
      max_hp: 1,
      sword_rotation: 0
    ]

    init_fly = Keyword.merge(defaults, opts)

    name = Keyword.get(init_fly, :name)
    x = Keyword.get(init_fly, :x)
    y = Keyword.get(init_fly, :y)
    velx = Keyword.get(init_fly, :velx)
    vely = Keyword.get(init_fly, :vely)
    hp = Keyword.get(init_fly, :hp)
    max_hp = Keyword.get(init_fly, :max_hp)
    sword_rotation = Keyword.get(init_fly, :sword_rotation)

    GenServer.start_link(
      __MODULE__,
      %State{
        name: name,
        x: x,
        y: y,
        hp: hp,
        velx: velx,
        vely: vely,
        max_hp: max_hp,
        sword_rotation: sword_rotation
      },
      name: __MODULE__
    )
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def state, do: GenServer.call(__MODULE__, :state)

  def handle_call(:state, _from, %State{} = state) do
    {:reply, state, state}
  end

  # def state, do: GenServer.call(__MODULE__, :take_damage)
  def take_damage(pid, amount) do
    IO.puts("DO_DAMAGE")

    GenServer.call(__MODULE__, {:take_damage, amount})
    # cond do
    #   hp + change <= 0 -> 0
    #   hp + change >= max_hp -> max_hp
    #   true -> hp + change
    # end
  end

  def handle_call({:take_damage, amount}, _from, %State{hp: hp} = state) do
    IO.puts("IN DO DAMAGE HANDLE ALL")
    new_hp = if hp - amount < 0, do: 0, else: hp - amount
    new_state = Map.merge(state, %{hp: new_hp})
    {:reply, new_state, new_state}
  end

  # def handle_call(:status, _from, %State{} = player) do
  #   {:reply, player, player}
  # end

  # def status(pid) do
  #   GenServer.call(pid, :status)
  # end
end
