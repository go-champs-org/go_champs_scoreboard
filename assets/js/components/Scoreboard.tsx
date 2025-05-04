import React from 'react';
import Main from './basketball_5x5/Main';
import { GameState, DEFAULT_GAME_STATE } from '../types';
import { FeatureFlagProvider } from '../shared/FeatureFlags';

const ScoreboardRegistry = {
  basketball: Main,
  default: () => <h1>Not Found</h1>,
};

interface ScoreboardProps {
  game_data: string;
  feature_flags_data?: string;
  pushEvent: (event: string, payload: any) => void;
  pushEventTo: (event: string, payload: any, selector: string) => void;
  handleEvent: (event: string, callback: (payload: any) => void) => void;
}

function Scoreboard({
  feature_flags_data = '{}',
  game_data,
  pushEvent,
}: ScoreboardProps) {
  const object = JSON.parse(game_data);
  const game_state = (object.result as GameState) || DEFAULT_GAME_STATE;
  const sportId = game_state.sport_id ? game_state.sport_id : 'default';
  const Component = ScoreboardRegistry[sportId];
  const isLoading = object.loading || false;

  return (
    <FeatureFlagProvider initialFlags={feature_flags_data}>
      <div className="container">
        {isLoading ? (
          <p>Loading...</p>
        ) : (
          <Component game_state={game_state} pushEvent={pushEvent} />
        )}
      </div>
    </FeatureFlagProvider>
  );
}

export default Scoreboard;
