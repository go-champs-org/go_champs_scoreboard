import React from 'react';
import { GameClockState } from '../../types';
import { formatTime } from '../../shared/contentHelpers';

interface StatsClockDisplayProps {
  clock_state: GameClockState;
}

function StatsClockDisplay({ clock_state }: StatsClockDisplayProps) {
  return (
    <div className="controls">
      <div className="columns is-multiline">
        <div className="column is-12 has-text-centered">
          <span className="chip-label">{clock_state.period}</span>
        </div>
        <div className="column is-12 has-text-centered">
          <span className="chip-label">{formatTime(clock_state.time)}</span>
        </div>
      </div>
    </div>
  );
}

export default StatsClockDisplay;
