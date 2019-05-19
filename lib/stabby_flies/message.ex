defmodule StabbyFlies.Message do
  @moduledoc """
  Description about this module
  """
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

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end
end
