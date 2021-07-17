use Mix.Config

# Configure your database
config :bullion, Bullion.Repo,
  username: "postgres",
  password: "postgres",
  database: "bullion",
  hostname: "localhost",
  port: 54321,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bullion, BullionWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
