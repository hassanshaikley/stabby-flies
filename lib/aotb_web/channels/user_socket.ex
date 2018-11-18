defmodule AotbWeb.UserSocket do
  use Phoenix.Socket

  require Logger

  ## Channels
  # channel "room:*", AotbWeb.RoomChannel
  channel "room:lobby", AotbWeb.RoomChannel


  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_params, socket, _connect_info) do
    id = Aotb.SocketIdGen.gen_id

    {:ok, assign(socket, :user_id, id)}
  end

  def disconnect(params, socket) do
    Logger.debug "DISCONENCT"
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     AotbWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(_socket), do: nil
  def id(socket), do: "#{socket.assigns.user_id}"

end
