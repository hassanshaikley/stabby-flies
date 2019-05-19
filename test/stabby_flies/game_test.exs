defmodule StabbyFlies.GameTest do
  use ExUnit.Case, async: true

  # setup do
  # game = start_supervised!(StabbyFlies.Game)
  # %{game: game}
  # end

  # test "spawns buckets", %{game: game} do
  #     # assert KV.Registry.lookup(game, "shopping") != :error

  #     # KV.Registry.create(game, "shopping")
  #     assert {:ok, bucket} = StabbyFlies.Game.lookup(game, "shopping")

  #     KV.Bucket.put(bucket, "milk", 1)
  #     assert KV.Bucket.get(bucket, "milk") == 1
  #   end

  test "adds p" do
    StabbyFlies.Game.add_player("player1", 1)
    assert StabbyFlies.Game.get_players() |> length == 1
  end

  test "removes p" do
    players_length = StabbyFlies.Game.get_players() |> length
    StabbyFlies.Game.add_player("player2", 2)
    StabbyFlies.Game.remove_player_by_socket_id(2)

    assert StabbyFlies.Game.get_players() |> length == players_length
  end

  # test "moves p" do
  #   player_three = StabbyFlies.Game.add_player("player3", 3)
  #   old_x = player_three[:x]
  #   StabbyFlies.Game.move_player_by_socket_id(3, "left")
  #   assert StabbyFlies.Game.get_player_by_socket_id(3)[:x] != old_x
  # end
end
