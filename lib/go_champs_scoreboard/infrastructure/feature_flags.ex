defmodule GoChampsScoreboard.Infrastructure.FeatureFlags do
  @moduledoc """
  Manages feature flags for the application.

  Feature flags allow toggling features on/off without code deployment.
  Flags are automatically disabled in production unless explicitly enabled.
  """

  # Define default flags - these can also be loaded from a config or database
  @flags %{
    "display_event_logs_modal" => true
  }

  @doc """
  Returns all feature flags and their statuses.
  Useful for admin interfaces.
  """
  def all_flags() do
    # In production, only show explicitly allowed flags
    case System.get_env("APP_ENV") do
      "production" ->
        get_production_allowed_flags()

      _ ->
        # In non-production, show all flags
        @flags
    end
  end

  # Returns a map of explicitly allowed flags in production
  defp get_production_allowed_flags do
    # Return same map as @flags with all flags set to false
    Enum.reduce(@flags, %{}, fn {key, _value}, acc ->
      Map.put(acc, key, false)
    end)
  end
end
