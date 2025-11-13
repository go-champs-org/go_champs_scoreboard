import React from 'react';
import {
  DEFAULT_PLAYER_STATE,
  EventLog,
  GameState,
  CoachState,
} from '../../types';
import { statIdToAbbreviationKey } from '../basketball_5x5/Stats/statsMapper';
import { useTranslation } from 'react-i18next';

function UpdatePlayerStatPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  const { t } = useTranslation();
  if (!eventLog.payload) return <></>;

  const team =
    eventLog.payload['team-type'] === 'home'
      ? gameState.home_team
      : gameState.away_team;
  const player =
    team.players.find((p) => p.id === eventLog.payload?.['player-id']) ||
    DEFAULT_PLAYER_STATE;
  const statKey = statIdToAbbreviationKey(eventLog.payload?.['stat-id']);
  return `${team.name} - ${player.name} | ${t(statKey)}`;
}

function UpdateCoachStatPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  const { t } = useTranslation();
  if (!eventLog.payload) return <></>;

  const team =
    eventLog.payload['team-type'] === 'home'
      ? gameState.home_team
      : gameState.away_team;
  const defaultCoach: CoachState = {
    id: '',
    name: '',
    type: 'head_coach',
    stats_values: {},
    state: 'available',
  };
  const coach =
    team.coaches.find((c) => c.id === eventLog.payload?.['coach-id']) ||
    defaultCoach;
  const statKey = statIdToAbbreviationKey(eventLog.payload?.['stat-id']);
  return `${team.name} - ${coach.name} | ${t(statKey)}`;
}

export default function EventLogPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  switch (eventLog.key) {
    case 'update-player-stat':
      return (
        <UpdatePlayerStatPayload eventLog={eventLog} gameState={gameState} />
      );
    case 'update-coach-stat':
      return (
        <UpdateCoachStatPayload eventLog={eventLog} gameState={gameState} />
      );
    default:
      return <></>;
  }
}
