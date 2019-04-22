defmodule StabbyFlies.Player do
  defstruct name: nil, x: nil, y: nil, hp: nil

  defguardp is_alive?(hp) when is_integer(hp) and hp > 0

  def alive?(%StabbyFlies.Player{hp: hp}) when is_alive?(hp), do: true
  def alive?(%StabbyFlies.Player{}), do: false

  def decrease_hp(%StabbyFlies.Player{hp: hp} = sprite, quantity) do
    %{sprite | hp: hp - quantity}
  end
end
