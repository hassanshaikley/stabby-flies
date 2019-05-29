defmodule StabbyFlies.GameNewTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.GameNew

  test "join_game" do
    StabbyFlies.GameNew.join_game("player1")
    assert StabbyFlies.GameNew.get_players() |> length == 1
  end
end
