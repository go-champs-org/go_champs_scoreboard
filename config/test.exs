import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :go_champs_scoreboard, GoChampsScoreboard.Repo,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  hostname: System.get_env("DATABASE_HOST") || "scoreboard-db",
  port: System.get_env("DATABASE_PORT") || "5432",
  database: "go_champs_scoreboard_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :go_champs_scoreboard, GoChampsScoreboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "I7o8zBiEBkf2URxf7xs4Sk+2f1JLwfjFUjPsJabWTMlydJxe/JYVMpSg2p6QiJPb",
  server: false

# In test we don't send emails
config :go_champs_scoreboard, GoChampsScoreboard.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# HTTP poison
config :go_champs_scoreboard, :http_client,
  http_client: GoChampsScoreboard.HTTPClientMock,
  url: "https://test.url"
