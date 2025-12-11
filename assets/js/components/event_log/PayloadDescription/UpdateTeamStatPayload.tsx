import React from 'react';
import { EventLog, GameState } from '../../../types';
import { teamStatIdToAbbreviationKey } from '../../basketball_5x5/Stats/statsMapper';
import { useTranslation } from 'react-i18next';
import TeamName from './TeamName';

export default function UpdateTeamStatPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  const { t } = useTranslation();
  if (!eventLog.payload) return <></>;

  const teamType = eventLog.payload['team-type'] as 'home' | 'away';
  const statKey = teamStatIdToAbbreviationKey(eventLog.payload?.['stat-id']);

  return (
    <>
      <TeamName gameState={gameState} teamType={teamType} /> | {t(statKey)}
    </>
  );
}
