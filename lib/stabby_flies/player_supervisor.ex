defmodule StabbyFlies.PlayerSupervisor do
  use DynamicSupervisor
  alias StabbyFlies.Player

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_player(player_options) do
    spec = Player.child_spec(player_options)

    with {:ok, _} <- DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, player_options[:name]}
    else
      {:error, {:already_started, pid}} ->
        {:error, "player #{player_options[:name]} already exists}"}

      {:error, {%ArgumentError{message: error_message}}} ->
        {:error, error_message}
    end
  end
end
