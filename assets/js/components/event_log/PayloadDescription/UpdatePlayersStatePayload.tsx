import React from 'react';
import { DEFAULT_PLAYER_STATE, EventLog, GameState } from '../../../types';
import { useTranslation } from 'react-i18next';

export default function UpdatePlayersStatePayload({
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

  const playerIds = eventLog.payload['player-ids'] || [];
  const state = eventLog.payload['state'];

  const players = playerIds.map(
    (playerId: string) =>
      team.players.find((p) => p.id === playerId) || DEFAULT_PLAYER_STATE,
  );

  const playerNumbers = players.map((p) => `#${p.number}`).join(', ');
  const stateText =
    state === 'playing'
      ? t('basketball.players.onCourt')
      : t('basketball.players.onBench');

  return `${team.name} - ${playerNumbers} | ${stateText}`;
}
