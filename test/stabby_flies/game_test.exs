defmodule StabbyFlies.GameTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.Game

  test "join_game" do
    StabbyFlies.Game.join_game("player1", "player1")
    assert StabbyFlies.Game.get_players() |> length == 1
  end

  test "leave_game" do
    old_length = StabbyFlies.Game.get_players() |> length

    StabbyFlies.Game.join_game("player1", "player1")

    StabbyFlies.Game.leave_game("player1")

    assert StabbyFlies.Game.get_players() |> length == old_length
  end

  test "player_state" do
    StabbyFlies.Game.join_game("player1", "player1")
    player = StabbyFlies.Game.player_state("player1")
    assert player.name == "player1"
  end
end
