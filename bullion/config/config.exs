# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bullion,
  ecto_repos: [Bullion.Repo]

# Configures the endpoint
config :bullion, BullionWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6TjB+DZ4VRcHWVHy/VEZb4iB2ECa1DAs+VBPwN6lG98NmW7mndkHge9wsrDahEp6",
  render_errors: [view: BullionWeb.ErrorView, accepts: ~w(html json)],
  reloadable_apps: [:bullion_core],
  pubsub_server: Bullion.PubSub

config :bullion_core,
  table_lookup_fn: &Bullion.TableV2.lookup_table/1,
  save_new_table_fn: &Bullion.TableV2.save_new_table/1,
  save_new_player_fn: &Bullion.TableV2.save_player/2,
  save_buyin_fn: &Bullion.TableV2.save_buyin/2,
  save_cashout_fn: &Bullion.TableV2.save_cashout/3

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
