defmodule StabbyFlies.GameNewTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.GameNew

  test "join_game" do
    StabbyFlies.GameNew.join_game("player1")
    assert StabbyFlies.GameNew.get_players() |> length == 1
  end

  test "leave_game" do
    StabbyFlies.GameNew.join_game("player1")
    StabbyFlies.GameNew.leave_game("player1")

    assert StabbyFlies.GameNew.get_players() |> length == 0
  end

  test "player_state" do
    StabbyFlies.GameNew.join_game("player1")
    player = StabbyFlies.GameNew.player_state("player1")
    assert player.name == "player1"
  end
end
