defmodule StabbyFliesWeb.UserSocket do
  use Phoenix.Socket

  require Logger

  # Was: channel "room:*", StabbyFliesWeb.RoomChannel
  channel "room:game", StabbyFliesWeb.RoomChannel

  def connect(_params, socket, _connect_info) do
    id = StabbyFlies.SocketIdGen.gen_id
    {:ok, assign(socket, :user_id, id)}
  end

  def disconnect(params, socket) do
    Logger.debug "DISCONENCT"
  end

  def id(socket), do: "#{socket.assigns.user_id}"

end
