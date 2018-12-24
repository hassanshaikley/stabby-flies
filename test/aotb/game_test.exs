defmodule Aotb.GameTest do
    use ExUnit.Case, async: true

    setup do
      # game = start_supervised!(Aotb.Game)
      # %{game: game}
    end
  
    # test "spawns buckets", %{game: game} do
    #     # assert KV.Registry.lookup(game, "shopping") != :error
    
    #     # KV.Registry.create(game, "shopping")
    #     assert {:ok, bucket} = Aotb.Game.lookup(game, "shopping")
    
    #     KV.Bucket.put(bucket, "milk", 1)
    #     assert KV.Bucket.get(bucket, "milk") == 1
    #   end

    test "adds p", %{game: game} do 
        player_one = Aotb.Game.add_player("playerone", 0)
        assert Aotb.Game.get_players.length == 1
    end

  end
  