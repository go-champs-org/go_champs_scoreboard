import React from 'react';
import { GameState } from '../../types';
import TeamControls, { BasicTeamControls } from './TeamControls';
import ClockControls from './ClockControls';
import ProtestControls from './ProtestControls';

interface TopControlsProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

export function BasicTopControls({ game_state }: TopControlsProps) {
  return (
    <div className="columns is-multiline">
      <div className="column is-6">
        <BasicTeamControls team={game_state.away_team} teamType="away" />
      </div>
      <div className="column is-6">
        <BasicTeamControls team={game_state.home_team} teamType="home" />
      </div>
    </div>
  );
}

function MediumTopControls({ game_state, pushEvent }: TopControlsProps) {
  return (
    <div className="columns is-multiline">
      <div className="column is-4">
        <TeamControls team={game_state.away_team} teamType="away" />
      </div>

      <div className="column is-4">
        {game_state.clock_state.state === 'finished' ? (
          <ProtestControls game_state={game_state} pushEvent={pushEvent} />
        ) : (
          <ClockControls
            home_team={game_state.home_team}
            away_team={game_state.away_team}
            clock_state={game_state.clock_state}
            live_state={game_state.live_state}
            pushEvent={pushEvent}
          />
        )}
      </div>

      <div className="column is-4">
        <div className="panel">
          <TeamControls team={game_state.home_team} teamType="home" />
        </div>
      </div>
    </div>
  );
}

export default MediumTopControls;
