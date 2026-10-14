defmodule GoChampsScoreboardWeb.Plugs.MetricsEndpoint do
  @moduledoc """
  Serves the Prometheus metrics at `/metrics`, guarded by a bearer token.

  The token comes from `config :go_champs_scoreboard, :metrics_token` (the
  `METRICS_TOKEN` env var in production). Without a token the endpoint answers
  404, so it is never exposed by accident.
  """

  @behaviour Plug

  import Plug.Conn

  @metrics_path "/metrics"

  @impl true
  def init(opts) do
    %{prom_ex: PromEx.Plug.init(prom_ex_module: Keyword.fetch!(opts, :prom_ex_module))}
  end

  @impl true
  def call(%Plug.Conn{request_path: @metrics_path} = conn, %{prom_ex: prom_ex}) do
    case authorize(conn) do
      :ok ->
        PromEx.Plug.call(conn, prom_ex)

      :not_configured ->
        conn |> send_resp(404, "Not Found") |> halt()

      :unauthorized ->
        conn
        |> put_resp_header("www-authenticate", "Bearer")
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  def call(conn, _opts), do: conn

  defp authorize(conn) do
    case Application.get_env(:go_champs_scoreboard, :metrics_token) do
      token when token in [nil, ""] -> :not_configured
      token -> check_bearer(get_req_header(conn, "authorization"), token)
    end
  end

  defp check_bearer(["Bearer " <> provided], token) do
    if Plug.Crypto.secure_compare(provided, token), do: :ok, else: :unauthorized
  end

  defp check_bearer(_header, _token), do: :unauthorized
end
