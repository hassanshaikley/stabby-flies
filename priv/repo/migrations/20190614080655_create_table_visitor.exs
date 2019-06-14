defmodule StabbyFlies.Repo.Migrations.CreateTableVisitor do
  use Ecto.Migration

  def change do
    create table("visitor") do
      add(:ip_address, :string, size: 40)
      add(:nickname, :string, size: 40)
    end
  end
end
