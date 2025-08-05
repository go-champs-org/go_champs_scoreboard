defmodule GoChampsScoreboard.Games.EventLogCacheBehavior do
  @moduledoc """
  Behavior for EventLogCache to enable mocking in tests.
  """

  @callback get(String.t()) ::
              {:ok, [GoChampsScoreboard.Events.EventLog.t()]} | {:error, :not_found}
  @callback add_event_log(String.t(), GoChampsScoreboard.Events.EventLog.t()) ::
              :ok | {:error, any()}
  @callback update(String.t(), [GoChampsScoreboard.Events.EventLog.t()]) :: :ok | {:error, any()}
  @callback refresh(String.t()) :: :ok | {:error, any()}
  @callback invalidate(String.t()) :: :ok | {:error, any()}
end
