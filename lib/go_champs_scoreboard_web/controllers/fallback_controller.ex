defmodule GoChampsScoreboardWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GoChampsScoreboardWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: GoChampsScoreboardWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: GoChampsScoreboardWeb.ErrorHTML, json: GoChampsScoreboardWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause handles errors returned by Ecto's when event update is the first of a game.
  def call(conn, {:error, :cannot_update_first_event_log}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      errors: %{
        detail: "Cannot update first event log"
      }
    })
  end

  # This clause handles errors when payload is invalid.
  def call(conn, {:error, :invalid_payload}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      errors: %{
        detail: "Invalid payload"
      }
    })
  end

  # This clause handles errors when no prior event log exists.
  def call(conn, {:error, :no_prior_event_log}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      errors: %{
        detail: "No prior event log found"
      }
    })
  end

  # This clause handles validation errors (like missing required fields).
  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      errors: %{
        detail: message
      }
    })
  end
end
