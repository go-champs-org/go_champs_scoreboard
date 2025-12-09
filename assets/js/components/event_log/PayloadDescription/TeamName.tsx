import React from 'react';
import { GameState } from '../../../types';

interface TeamNameProps {
  gameState: GameState;
  teamType: 'home' | 'away';
}

export default function TeamName({ gameState, teamType }: TeamNameProps) {
  const team = teamType === 'home' ? gameState.home_team : gameState.away_team;
  return <>{team.name}</>;
}
