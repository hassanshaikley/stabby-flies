defmodule StabbyFlies.Player do
  defstruct name: "Poopsy", x: nil, y: nil, velx: 0, vely: 0, hp: nil

  defguardp is_alive?(hp) when is_integer(hp) and hp > 0

  def alive?(%StabbyFlies.Player{hp: hp}) when is_alive?(hp), do: true
  def alive?(%StabbyFlies.Player{}), do: false

  def decrease_hp(%StabbyFlies.Player{hp: hp} = player, quantity) do
    %{player | hp: hp - quantity}
  end

  def move_right(%StabbyFlies.Player{velx: velx, hp: hp} = player, quantity \\ 1) do
    # when is_alive?(hp) do
    %StabbyFlies.Player{player | velx: quantity}
  end

  def move_left(%StabbyFlies.Player{velx: velx, hp: hp} = player, quantity \\ 1) do
    %StabbyFlies.Player{player | velx: -1 * quantity}
  end

  def move_up(%StabbyFlies.Player{vely: vely, hp: hp} = player, quantity \\ 1) do
    %StabbyFlies.Player{player | vely: -1 * quantity}
  end

  def move_down(%StabbyFlies.Player{vely: vely, hp: hp} = player, quantity \\ 1) do
    %StabbyFlies.Player{player | vely: 1 * quantity}
  end
end
