import React from 'react';
import { GameState } from '../../types';
import { BasicTeamControls } from './TeamControls';

interface TopControlsProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

export function BasicTopControls({ game_state }: TopControlsProps) {
  return (
    <div className="columns is-multiline">
      <div className="column is-6">
        <BasicTeamControls
          team={game_state.home_team}
          clock_state={game_state.clock_state}
          teamType="home"
        />
      </div>
      <div className="column is-6">
        <BasicTeamControls
          team={game_state.away_team}
          clock_state={game_state.clock_state}
          teamType="away"
        />
      </div>
    </div>
  );
}
