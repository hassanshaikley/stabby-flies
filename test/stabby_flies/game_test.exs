defmodule StabbyFliesGameTest do
  use ExUnit.Case, async: true
  alias StabbyFliesGame

  test "join_game" do
    StabbyFliesGame.join_game("player1")
    assert StabbyFliesGame.get_players() |> length == 1
  end

  test "leave_game" do
    StabbyFliesGame.join_game("player1")
    StabbyFliesGame.leave_game("player1")

    assert StabbyFliesGame.get_players() |> length == 0
  end

  test "player_state" do
    StabbyFliesGame.join_game("player1")
    player = StabbyFliesGame.player_state("player1")
    assert player.name == "player1"
  end
end
