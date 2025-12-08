import React from 'react';
import { EventLog, GameState, CoachState } from '../../../types';
import { statIdToAbbreviationKey } from '../../basketball_5x5/Stats/statsMapper';
import { useTranslation } from 'react-i18next';

export default function UpdateCoachStatPayload({
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
