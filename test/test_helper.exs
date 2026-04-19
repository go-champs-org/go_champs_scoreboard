ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GoChampsScoreboard.Repo, :manual)
Mox.defmock(GoChampsScoreboard.HTTPClientMock, for: HTTPoison.Base)

Mox.defmock(GoChampsScoreboard.Infrastructure.GameTickerSupervisorMock,
  for: GoChampsScoreboard.Infrastructure.GameTickerSupervisorBehavior
)

Mox.defmock(GoChampsScoreboard.Infrastructure.GameEventsListenerSupervisorMock,
  for: GoChampsScoreboard.Infrastructure.GameEventsListenerSupervisorBehavior
)

Mox.defmock(GoChampsScoreboard.Infrastructure.GameEventLogsListenerSupervisorMock,
  for: GoChampsScoreboard.Infrastructure.GameEventLogsListenerSupervisorBehavior
)

Mox.defmock(GoChampsScoreboard.Games.Messages.PubSubMock,
  for: GoChampsScoreboard.Games.Messages.PubSubBehavior
)

Mox.defmock(GoChampsScoreboard.Games.ResourceManagerMock,
  for: GoChampsScoreboard.Games.ResourceManagerBehavior
)

Mox.defmock(GoChampsScoreboard.Games.EventLogCacheMock,
  for: GoChampsScoreboard.Games.EventLogCacheBehavior
)
