defmodule Aotb.GameTest do
    use ExUnit.Case, async: true

    # setup do
      # game = start_supervised!(Aotb.Game)
      # %{game: game}
    # end
  
    # test "spawns buckets", %{game: game} do
    #     # assert KV.Registry.lookup(game, "shopping") != :error
    
    #     # KV.Registry.create(game, "shopping")
    #     assert {:ok, bucket} = Aotb.Game.lookup(game, "shopping")
    
    #     KV.Bucket.put(bucket, "milk", 1)
    #     assert KV.Bucket.get(bucket, "milk") == 1
    #   end

    test "adds p" do 
        player_one = Aotb.Game.add_player("player1", 1)
        assert Aotb.Game.get_players |> length == 1
    end

    test "removes p" do 
      players_length = Aotb.Game.get_players |> length
      Aotb.Game.add_player("player2", 2)
      Aotb.Game.remove_player_by_socket_id(2)

      assert Aotb.Game.get_players |> length == players_length
    end


    test "moves p" do 
      player_three = Aotb.Game.add_player("player3", 3)
      old_x = player_three[:x]
      Aotb.Game.move_player_by_socket_id(3, "left")
      assert Aotb.Game.get_player_by_socket_id(3)[:x] != old_x
    end


  end
  