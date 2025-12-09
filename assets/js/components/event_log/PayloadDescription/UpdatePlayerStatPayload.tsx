import React from 'react';
import { EventLog, GameState } from '../../../types';
import { statIdToAbbreviationKey } from '../../basketball_5x5/Stats/statsMapper';
import { useTranslation } from 'react-i18next';
import TeamName from './TeamName';
import PlayerNumbers from './PlayerNumbers';

export default function UpdatePlayerStatPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  const { t } = useTranslation();
  if (!eventLog.payload) return <></>;

  const teamType = eventLog.payload['team-type'] as 'home' | 'away';
  const playerId = eventLog.payload['player-id'];
  const statKey = statIdToAbbreviationKey(eventLog.payload?.['stat-id']);

  return (
    <>
      <TeamName gameState={gameState} teamType={teamType} /> -{' '}
      <PlayerNumbers
        gameState={gameState}
        teamType={teamType}
        playerIds={[playerId]}
      />{' '}
      | {t(statKey)}
    </>
  );
}
