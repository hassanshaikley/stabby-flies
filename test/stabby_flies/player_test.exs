defmodule StabbyFlies.PlayerTest do
  use ExUnit.Case, async: true

  test "struct stuff ??" do
    player_one = %StabbyFlies.Player{name: "John", x: 15, y: 10}
    assert player_one.name == "John"
    assert player_one.x == 15
    assert player_one.y == 10
  end
end
