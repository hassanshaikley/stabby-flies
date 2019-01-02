# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stabby_flies,
  ecto_repos: [StabbyFlies.Repo]

# Configures the endpoint
config :stabby_flies, StabbyFliesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Al0xchNKPZ9roanAVIWcpK8d4IyM1rbyYxIGHvkP60f9VF7SNa9qjAV3n31KtsMO",
  render_errors: [view: StabbyFliesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: StabbyFlies.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

if (Mix.env() != "prod") do
  import_config "#{Mix.env()}.exs"
end
