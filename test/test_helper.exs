ExUnit.start()
# Ecto.Adapters.SQL.Sandbox.mode(GoChampsScoreboard.Repo, :manual)
Mox.defmock(GoChampsScoreboard.HTTPClientMock, for: HTTPoison.Base)

Mox.defmock(GoChampsScoreboard.Infrastructure.GameCaptureTemporalStatsSupervisorMock,
  for: GoChampsScoreboard.Infrastructure.GameCaptureTemporalStatsSupervisorBehavior
)

Mox.defmock(GoChampsScoreboard.Infrastructure.GameTickerSupervisorMock,
  for: GoChampsScoreboard.Infrastructure.GameTickerSupervisorBehavior
)

Mox.defmock(GoChampsScoreboard.Infrastructure.GameEventStreamerSupervisorMock,
  for: GoChampsScoreboard.Infrastructure.GameEventStreamerSupervisorBehavior
)

Mox.defmock(GoChampsScoreboard.Games.ResourceManagerMock,
  for: GoChampsScoreboard.Games.ResourceManagerBehavior
)
