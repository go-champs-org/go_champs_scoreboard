defmodule GoChampsScoreboard.PromEx do
  @moduledoc """
  Prometheus metrics for the scoreboard (HTTP latency per route, Ecto, BEAM and
  the live game pipeline).

  Scraped through `GET /metrics`, see `GoChampsScoreboardWeb.Plugs.MetricsEndpoint`.
  """

  use PromEx, otp_app: :go_champs_scoreboard

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix,
       router: GoChampsScoreboardWeb.Router, endpoint: GoChampsScoreboardWeb.Endpoint},
      {Plugins.Ecto, repos: [GoChampsScoreboard.Repo]},
      GoChampsScoreboard.PromEx.GamePlugin
    ]
  end

  @impl true
  def dashboard_assigns do
    []
  end

  @impl true
  def dashboards do
    []
  end
end
