defmodule GoChampsScoreboard.Repo do
  use Ecto.Repo,
    otp_app: :go_champs_scoreboard,
    adapter: Ecto.Adapters.Postgres
end
