# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ptah,
  ecto_repos: [Ptah.Repo]

config :ptah,
  event_stores: [Ptah.EventStore]

# Commanded projections
config :commanded_ecto_projections,
  repo: Ptah.Repo

# Configures the endpoint
config :ptah, PtahWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: PtahWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ptah.PubSub,
  live_view: [signing_salt: "2D2s0Hah"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
