import React from 'react';
import { GameState } from '../../types';
import RegisterProtest from './RegisterProtest';
import ProtestRegistered from './ProtestRegistered';

interface ProtestControlsProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function ProtestControls({ game_state, pushEvent }: ProtestControlsProps) {
  const isProtestRegistered = game_state.protest.state === 'protest_filed';

  if (isProtestRegistered) {
    return <ProtestRegistered game_state={game_state} />;
  }

  return <RegisterProtest game_state={game_state} pushEvent={pushEvent} />;
}

export default ProtestControls;
