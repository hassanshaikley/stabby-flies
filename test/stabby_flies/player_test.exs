defmodule StabbyFlies.PlayerTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.Player

  setup do
    player = %Player{name: "John", x: 15, y: 10, hp: 10, velx: 0, vely: 0}

    %{player: player}
  end

  test "initialization", %{player: player} do
    assert player.name == "John"
    assert player.x == 15
    assert player.y == 10
    assert player.vely == 0
    assert player.velx == 0
  end

  test "alive? function", %{player: player} do
    dead_player = %Player{name: "John", x: 15, y: 10, hp: 0}

    assert Player.alive?(player) == true
    assert Player.alive?(dead_player) == false
  end

  test "decrease_hp function", %{player: player} do
    assert Player.decrease_hp(player, 2).hp == 8
  end
end
