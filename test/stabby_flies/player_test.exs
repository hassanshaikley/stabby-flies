defmodule StabbyFlies.PlayerTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.Player

  setup do
    player =
      start_supervised!({Player, name: "Faa", x: 15, y: 10, hp: 1, max_hp: 1, sword_rotation: 0})

    %{player: player}
  end

  test "initialization", %{player: player} do
    player_state = Player.state(player)
    assert player_state.name == "Faa"
    assert player_state.x != nil
    assert player_state.y != nil
    assert player_state.hp == 1
    assert player_state.max_hp == 1
    assert player_state.sword_rotation == 0
  end

  test "take damage", %{player: player} do
    Player.take_damage(player, 999)
    player_state = Player.state(player)
    assert player_state.hp == 0
  end

  test "updates position based on velocity", %{player: player} do
    %{x: x, y: y} = Player.state(player)

    Player.update_position(player)
    player_state = Player.state(player)
    assert x != player_state.x
    assert y != player_state.y
  end

  test "can_stab", %{player: player} do
    assert Player.can_stab(player) == true
  end

  test "reset stab cooldown", %{player: player} do
    Player.reset_stab_cooldown(player)
    assert Player.can_stab(player) == false
  end

  test "respawn", %{player: player} do
    Player.take_damage(player, 999)
    Player.respawn(player)
    player_state = Player.state(player)
    assert player_state.hp == player_state.max_hp
  end

  test "increment kill count", %{player: player} do
    old_kill_count = Player.state(player).kill_count
    Player.increment_kill_count(player)
    player_state = Player.state(player)
    assert old_kill_count + 1 == player_state.kill_count
  end

  test "update moving", %{player: player} do
    new_moving = %{
      left: true,
      right: true,
      up: false,
      down: false
    }

    Player.update_moving(player, new_moving)
    player_state = Player.state(player)
    assert player_state.moving == new_moving
  end
end
