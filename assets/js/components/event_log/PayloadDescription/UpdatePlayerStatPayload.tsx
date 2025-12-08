import React from 'react';
import { DEFAULT_PLAYER_STATE, EventLog, GameState } from '../../../types';
import { statIdToAbbreviationKey } from '../../basketball_5x5/Stats/statsMapper';
import { useTranslation } from 'react-i18next';

export default function UpdatePlayerStatPayload({
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
