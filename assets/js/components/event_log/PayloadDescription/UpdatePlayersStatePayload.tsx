import React from 'react';
import { EventLog, GameState } from '../../../types';
import { useTranslation } from 'react-i18next';
import TeamName from './TeamName';
import PlayerNumbers from './PlayerNumbers';

export default function UpdatePlayersStatePayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  const { t } = useTranslation();
  if (!eventLog.payload) return <></>;

  const teamType = eventLog.payload['team-type'] as 'home' | 'away';
  const playerIds = eventLog.payload['player-ids'] || [];
  const state = eventLog.payload['state'];

  const stateText =
    state === 'playing'
      ? t('basketball.players.onCourt')
      : t('basketball.players.onBench');

  return (
    <>
      <TeamName gameState={gameState} teamType={teamType} /> -{' '}
      <PlayerNumbers
        gameState={gameState}
        teamType={teamType}
        playerIds={playerIds}
      />{' '}
      | {stateText}
    </>
  );
}
