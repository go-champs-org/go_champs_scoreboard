import React from 'react';
import { EventLog, GameState } from '../../types';
import { useTranslation } from 'react-i18next';
import { EVENT_KEYS } from '../../constants';
import UpdatePlayerStatPayload from './PayloadDescription/UpdatePlayerStatPayload';
import UpdateCoachStatPayload from './PayloadDescription/UpdateCoachStatPayload';
import UpdatePlayersStatePayload from './PayloadDescription/UpdatePlayersStatePayload';

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
    default:
      return <></>;
  }
}
