defmodule StabbyFliesWeb.PageController do
  use StabbyFliesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
