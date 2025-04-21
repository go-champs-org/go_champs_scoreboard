defmodule GoChampsScoreboardWeb.Router do
  alias GoChampsScoreboardWeb.ScoreboardReportViewers
  alias GoChampsScoreboardWeb.ErrorController
  alias GoChampsScoreboardWeb.ScoreboardController
  alias GoChampsScoreboardWeb.ScoreboardControlLive
  alias GoChampsScoreboardWeb.ScoreboardStreamViewsLive
  use GoChampsScoreboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GoChampsScoreboardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GoChampsScoreboardWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", GoChampsScoreboardWeb do
  #   pipe_through :api
  # end

  scope "/error" do
    pipe_through :browser

    get "/", ErrorController, :show
  end

  scope "/scoreboard" do
    pipe_through :browser

    get "/load/:game_id", ScoreboardController, :load
    live "/control/:game_id", ScoreboardControlLive
    live "/report_viewer/:game_id", ScoreboardReportViewers
    live "/stream_views/:game_id", ScoreboardStreamViewsLive
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:go_champs_scoreboard, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GoChampsScoreboardWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
