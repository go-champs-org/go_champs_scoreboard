import { EventLog, GameState } from '../../types';

function EventDetails({
  event,
  gameState,
}: {
  event: EventLog;
  gameState: GameState;
}) {
  const { payload } = event;
  if (!payload) {
    return <></>;
  }

  const team =
    payload['team-type'] === 'away' ? gameState.away_team : gameState.home_team;
  const player = team.players.find((p) => p.id === payload['player-id']);
  return (
    <div>
      <span className="team">{team.name}</span>
      <span className="player">{`${player?.number} - ${player?.name}`}</span>
    </div>
  );
}

function EventKey({ eventKey }: { eventKey: string }) {
  return <span>{eventKey}</span>;
}

function EventLog({
  event,
  gameState,
}: {
  event: EventLog;
  gameState: GameState;
}) {
  const formatTime = (time: number) => {
    const minutes = Math.floor(time / 60);
    const seconds = time % 60;
    const minutesStr = minutes < 10 ? `0${minutes}` : minutes;
    const secondsStr = seconds < 10 ? `0${seconds}` : seconds;
    return `${minutesStr}:${secondsStr}`;
  };
  return (
    <div className="event-log">
      <div className="clock-state">
        <span className="period">{event.game_clock_period}</span>
        <span className="time">{formatTime(event.game_clock_time)}</span>
      </div>
      <div className="event-key">
        <EventKey eventKey={event.key} />
      </div>
      <div className="event-details">
        <EventDetails event={event} gameState={gameState} />
      </div>
    </div>
  );
}

function RecentEventLogs({
  recentEvents,
  gameState,
}: {
  recentEvents: EventLog[];
  gameState: GameState;
}) {
  return (
    <div className="columns is-multiline">
      {recentEvents.map((event, index) => (
        <div key={index} className="column is-12">
          <EventLog event={event} gameState={gameState} />
        </div>
      ))}
    </div>
  );
}

export default RecentEventLogs;
