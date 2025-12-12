import React from 'react';
import { EventLog, GameState, CoachState } from '../../../types';
import { coachStatIdToAbbreviationKey } from '../../basketball_5x5/Stats/statsMapper';
import { useTranslation } from 'react-i18next';
import TeamName from './TeamName';
import DisplayCoach from './DisplayCoach';

export default function UpdateCoachStatPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  const { t } = useTranslation();
  if (!eventLog.payload) return <></>;

  const teamType = eventLog.payload['team-type'] as 'home' | 'away';
  const team = teamType === 'home' ? gameState.home_team : gameState.away_team;

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
  const statKey = coachStatIdToAbbreviationKey(eventLog.payload?.['stat-id']);

  return (
    <>
      <TeamName gameState={gameState} teamType={teamType} /> -{' '}
      <DisplayCoach coach={coach} /> | {t(statKey)}
    </>
  );
}
