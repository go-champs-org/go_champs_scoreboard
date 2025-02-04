defmodule GoChampsScoreboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_username = System.get_env("REDIS_USERNAME") || nil
    redis_password = System.get_env("REDIS_PASSWORD") || nil
    redis_url = System.get_env("REDIS_URL") || "redis"

    children = [
      GoChampsScoreboardWeb.Telemetry,
      {DynamicSupervisor,
       name: GoChampsScoreboard.Infrastructure.GameTickerSupervisor, strategy: :one_for_one},
      {DynamicSupervisor,
       name: GoChampsScoreboard.Infrastructure.GameEventStreamerSupervisor, strategy: :one_for_one},
      {Registry,
       keys: :unique, name: GoChampsScoreboard.Infrastructure.GameEventStreamerRegistry},
      {Registry, keys: :unique, name: GoChampsScoreboard.Infrastructure.GameTickerRegistry},
      GoChampsScoreboard.Infrastructure.RabbitMQ,
      {DNSCluster,
       query: Application.get_env(:go_champs_scoreboard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GoChampsScoreboard.PubSub},
      {Redix,
       {"redis://#{redis_url}",
        [name: :games_cache, username: redis_username, password: redis_password]}},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GoChampsScoreboard.Finch},
      # Start a worker by calling: GoChampsScoreboard.Worker.start_link(arg)
      # {GoChampsScoreboard.Worker, arg},
      # Start to serve requests, typically the last entry
      GoChampsScoreboardWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GoChampsScoreboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
