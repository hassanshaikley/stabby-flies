defmodule StabbyFlies.Message do
  use Ecto.Schema
  import Ecto.Changeset


  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps()
  end

  def get_messages(limit \\ 20) do
    StabbyFlies.Repo.all(StabbyFlies.Message, limit: limit)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end
end
