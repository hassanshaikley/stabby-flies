defmodule StabbyFlies.PlayerSupervisorTest do
  use ExUnit.Case, async: false
  alias StabbyFlies.PlayerSupervisor

  #   setup do
  #     player =
  #       start_supervised!(
  #         {Player, name: "Faa", x: 15, y: 10, velx: 1, vely: 1, hp: 1, max_hp: 1, sword_rotation: 0}
  #       )

  #     %{player: player}
  #   end

  test "initialization" do
    PlayerSupervisor.create_player(name: "Farticus")
    PlayerSupervisor.create_player(name: "Farticus-Duex")
    assert PlayerSupervisor.players() |> length == 2
  end

  test "deletion" do
    PlayerSupervisor.create_player(name: "Farticus")

    PlayerSupervisor.delete_player("Farticus")

    assert PlayerSupervisor.players() |> length == 0
  end
end
