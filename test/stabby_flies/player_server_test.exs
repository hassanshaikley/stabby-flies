defmodule StabbyFlies.PlayerServerTest do
  use ExUnit.Case, async: true
  alias StabbyFlies.{Player, PlayerServer}

  setup do
    player_server = start_supervised!(PlayerServer, %{})
    %{player_server: player_server}
  end

  test "spawns players", %{player_server: player_server} do
    status = PlayerServer.status(player_server) |> IO.inspect()
    assert status != nil
    # assert PlayerServerstatus(pid)

    # assert KV.Registry.lookup(registry, "shopping") == :error

    # KV.Registry.create(registry, "shopping")
    # assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # KV.Bucket.put(bucket, "milk", 1)
    # assert KV.Bucket.get(bucket, "milk") == 1
  end
end
