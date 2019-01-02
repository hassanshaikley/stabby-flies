defmodule StabbyFlies.Repo do
  use Ecto.Repo,
    otp_app: :stabby_flies,
    adapter: Ecto.Adapters.Postgres
end
