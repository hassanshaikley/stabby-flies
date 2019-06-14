defmodule StabbyFlies.Visitor do
  use Ecto.Schema

  schema "visitor" do
    field :ip_address, :string
    field :nickname, :string
  end
end
