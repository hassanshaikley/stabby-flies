defmodule StabbyFlies.PlayerTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.Player

  setup do
    player =
      start_supervised!(
        {Player, name: "Faa", x: 15, y: 10, velx: 0, vely: 0, hp: 1, max_hp: 1, sword_rotation: 0}
      )

    %{player: player}
  end

  test "initialization", %{player: player} do
    player_state = Player.state()
    assert player_state.name == "Faa"
    assert player_state.x != nil
    assert player_state.y != nil
    assert player_state.vely == 0
    assert player_state.velx == 0
    assert player_state.hp == 1
    assert player_state.max_hp == 1
    assert player_state.sword_rotation == 0
  end

  test "do damage", %{player: player} do
    player_state = Player.take_damage(player, 999)
    player_state = Player.state()
    assert player_state.hp == 0
  end

  # test "spawns players", %{player: player} do
  #   status = Player.status(player) |> IO.inspect()
  #   assert status != nil
  # end

  # test "alive? function", %{player: player} do
  #   dead_player = %Player{name: "John", x: 15, y: 10, hp: 0}

  #   assert Player.alive?(player) == true
  #   assert Player.alive?(dead_player) == false
  # end

  # test "decrease_hp function", %{player: player} do
  #   assert Player.decrease_hp(player, 2).hp == 8
  # end
end
