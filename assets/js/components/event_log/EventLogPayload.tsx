import React from 'react';
import { EventLog, GameState } from '../../types';
import { EVENT_KEYS } from '../../constants';
import UpdatePlayerStatPayload from './PayloadDescription/UpdatePlayerStatPayload';
import UpdateCoachStatPayload from './PayloadDescription/UpdateCoachStatPayload';
import UpdatePlayersStatePayload from './PayloadDescription/UpdatePlayersStatePayload';
import UpdateTeamStatPayload from './PayloadDescription/UpdateTeamStatPayload';

export default function EventLogPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  switch (eventLog.key) {
    case EVENT_KEYS.UPDATE_PLAYER_STAT:
      return (
        <UpdatePlayerStatPayload eventLog={eventLog} gameState={gameState} />
      );
    case EVENT_KEYS.UPDATE_COACH_STAT:
      return (
        <UpdateCoachStatPayload eventLog={eventLog} gameState={gameState} />
      );
    case EVENT_KEYS.UPDATE_PLAYERS_STATE:
      return (
        <UpdatePlayersStatePayload eventLog={eventLog} gameState={gameState} />
      );
    case EVENT_KEYS.UPDATE_TEAM_STAT:
      return (
        <UpdateTeamStatPayload eventLog={eventLog} gameState={gameState} />
      );
    default:
      return <></>;
  }
}
