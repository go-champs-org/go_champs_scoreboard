import React from 'react';
import { GameClockState, LiveState, TeamState } from '../../types';
import { invokeButtonClickRef } from '../../shared/invokeButtonClick';
import { FeatureFlag } from '../../shared/FeatureFlags';

interface ClockControlsProps {
  away_team: TeamState;
  home_team: TeamState;
  clock_state: GameClockState;
  live_state: LiveState;
  pushEvent: (event: string, payload: any) => void;
}

function formatTime(time: number) {
  const minutes = Math.floor(time / 60);
  const seconds = time % 60;
  const minutesStr = minutes < 10 ? `0${minutes}` : minutes;
  const secondsStr = seconds < 10 ? `0${seconds}` : seconds;
  return `${minutesStr}:${secondsStr}`;
}

function ClockControls({
  away_team,
  home_team,
  clock_state,
  live_state,
  pushEvent,
}: ClockControlsProps) {
  const buttonPauseStart = React.useRef<HTMLButtonElement>(null);
  const clockButtonsDisabled = live_state?.state !== 'in_progress';
  const isGameTied =
    away_team.total_player_stats['points'] ===
    home_team.total_player_stats['points'];
  const endQuarterButtonDisabled =
    clock_state.period >= 4 ? !isGameTied : false;
  const onPauseStartClock = () => {
    if (clock_state.state === 'running') {
      pushEvent('update-clock-state', { state: 'paused' });
    } else {
      pushEvent('update-clock-state', { state: 'running' });
    }
  };
  const onTimeIncrement = () => {
    pushEvent('update-clock-time-and-period', {
      property: 'time',
      operation: 'increment',
    });
  };
  const onTimeIncrement60 = () => {
    pushEvent('update-clock-time-and-period', {
      property: 'time',
      operation: 'increment60',
    });
  };
  const onTimeDecrement = () => {
    pushEvent('update-clock-time-and-period', {
      property: 'time',
      operation: 'decrement',
    });
  };
  const onTimeDecrement60 = () => {
    pushEvent('update-clock-time-and-period', {
      property: 'time',
      operation: 'decrement60',
    });
  };

  const onEndQuarter = () => {
    pushEvent('end-period', {});
  };

  React.useEffect(() => {
    const listener = (event: KeyboardEvent) => {
      const { key } = event;
      if (key === ' ') {
        event.preventDefault();
        invokeButtonClickRef(buttonPauseStart);
      }
    };

    document.addEventListener('keydown', listener);
    return () => document.removeEventListener('keydown', listener);
  }, [buttonPauseStart, clock_state]);

  const TimeoutControls = () => (
    <>
      <div className="column is-4">
        <button
          className="button is-info"
          onClick={() =>
            pushEvent('update-team-stat', {
              ['stat-id']: 'timeouts',
              ['team-type']: 'home',
              operation: 'increment',
            })
          }
          disabled={clockButtonsDisabled}
        >
          {'Timeout'}
        </button>
      </div>
      <div className="column is-4">
        <span className="chip-label">{clock_state.period}</span>
      </div>
      <div className="column is-4">
        <button
          className="button is-info"
          onClick={() =>
            pushEvent('update-team-stat', {
              ['stat-id']: 'timeouts',
              ['team-type']: 'away',
              operation: 'increment',
            })
          }
          disabled={clockButtonsDisabled}
        >
          {'Timeout'}
        </button>
      </div>
    </>
  );

  return (
    <div className="controls">
      <div className="columns is-multiline">
        <TimeoutControls />

        <div className="column is-2">
          <button
            className="button is-info has-tooltip"
            data-tooltip="- 1 Min"
            onClick={onTimeIncrement60}
            disabled={clockButtonsDisabled}
          >
            {'<<'}
          </button>
        </div>
        <div className="column is-2">
          <button
            className="button is-info"
            data-tooltip="- 1 Seg"
            onClick={onTimeIncrement}
            disabled={clockButtonsDisabled}
          >
            {'<'}
          </button>
        </div>
        <div className="column is-4">
          <span className="chip-label">{formatTime(clock_state.time)}</span>
        </div>
        <div className="column is-2">
          <button
            className="button is-info"
            data-tooltip="+ 1 Seg"
            onClick={onTimeDecrement}
            disabled={clockButtonsDisabled}
          >
            {'>'}
          </button>
        </div>
        <div className="column is-2">
          <button
            className="button is-info"
            data-tooltip="+ 1 Min"
            onClick={onTimeDecrement60}
            disabled={clockButtonsDisabled}
          >
            {'>>'}
          </button>
        </div>

        <div className="column is-12">
          {clock_state.time === 0 ? (
            <button
              className="button is-warning is-fullwidth"
              onClick={onEndQuarter}
              disabled={endQuarterButtonDisabled}
            >
              End quarter
            </button>
          ) : (
            <button
              ref={buttonPauseStart}
              className="button is-info is-fullwidth"
              onClick={onPauseStartClock}
              disabled={clockButtonsDisabled}
            >
              <span className="shortcut">ESPACE</span>
              {clock_state.state === 'running' ? 'Pause' : 'Start'}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

export default ClockControls;
