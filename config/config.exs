# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :discuss,
  ecto_repos: [Discuss.Repo]

# Configures the endpoint
config :discuss, Discuss.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rgB70EXa43WNBJjBGB8MUYFN3pMzs9/sLofaqxdXa+BbaZTGpIAdeUoBCQa+QoPo",
  render_errors: [view: Discuss.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Discuss.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure Ueberauth
# ___________________
config :ueberauth, Ueberauth,
  providers: [ 
    github: { Ueberauth.Strategy.Github, [] }
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "93aeaf93c76de1ec2758",
  client_secret: "f8ebb8261fb42030bba58c81030b1d1372a45f9a"
