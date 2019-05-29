defmodule StabbyFlies.PlayerSupervisorTest do
  use ExUnit.Case, async: false
  alias StabbyFlies.PlayerSupervisor

  setup do
    reset
    []
  end

  test "initialization" do
    PlayerSupervisor.create_player(name: "Farticus")
    PlayerSupervisor.create_player(name: "Farticus-Duex")
    assert PlayerSupervisor.players() |> length == 2
  end

  test "deletion" do
    PlayerSupervisor.create_player(name: "Farticus-Prime")
    PlayerSupervisor.delete_player("Farticus-Prime")

    assert PlayerSupervisor.players() |> length == 0
  end

  defp reset do
    PlayerSupervisor.reset()
  end
end
