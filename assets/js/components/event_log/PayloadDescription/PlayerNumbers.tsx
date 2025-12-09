import React from 'react';
import { DEFAULT_PLAYER_STATE, GameState } from '../../../types';

interface PlayerNumbersProps {
  gameState: GameState;
  teamType: 'home' | 'away';
  playerIds: string[];
}

export default function PlayerNumbers({
  gameState,
  teamType,
  playerIds,
}: PlayerNumbersProps) {
  const team = teamType === 'home' ? gameState.home_team : gameState.away_team;

  const players = playerIds.map(
    (playerId: string) =>
      team.players.find((p) => p.id === playerId) || DEFAULT_PLAYER_STATE,
  );

  const playerNumbers = players.map((p) => `#${p.number}`).join(', ');

  return <>{playerNumbers}</>;
}
