defmodule StabbyFlies.PlayerTest do
  use ExUnit.Case, async: false
  alias StabbyFlies.Player

  setup do
    player =
      start_supervised!(
        {Player, name: "Faa", x: 15, y: 10, velx: 1, vely: 1, hp: 1, max_hp: 1, sword_rotation: 0}
      )

    %{player: player}
  end

  test "initialization", %{player: player} do
    player_state = Player.state(player)
    assert player_state.name == "Faa"
    assert player_state.x != nil
    assert player_state.y != nil
    assert player_state.vely == 1
    assert player_state.velx == 1
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

  # Ok this test should use start_supervised! :()
  test "spawns another player" do
    Player.start_link(
      name: "xyz",
      x: 15,
      y: 10,
      velx: 1,
      vely: 1,
      hp: 1,
      max_hp: 1,
      sword_rotation: 0
    )
  end

  test "can_stab", %{player: player} do
    assert Player.can_stab(player) == true
  end

  test "reset stab cooldown", %{player: player} do
    Player.reset_stab_cooldown(player)
    assert Player.can_stab(player) == false
  end

  # test "alive? function", %{player: player} do
  #   dead_player = %Player{name: "John", x: 15, y: 10, hp: 0}

  #   assert Player.alive?(player) == true
  #   assert Player.alive?(dead_player) == false
  # end

  # test "decrease_hp function", %{player: player} do
  #   assert Player.decrease_hp(player, 2).hp == 8
  # end
end
