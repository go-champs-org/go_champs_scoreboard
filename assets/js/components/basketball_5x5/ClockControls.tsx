import React from 'react';
import { GameClockState, LiveState, TeamState } from '../../types';
import { invokeButtonClickRef } from '../../shared/invokeButtonClick';

interface ClockControlsProps {
  away_team: TeamState;
  home_team: TeamState;
  clock_state: GameClockState;
  live_state: LiveState;
  pushEvent: (event: string, payload: any) => void;
}

interface InGameClockControlsProps {
  clock_state: GameClockState;
  clockButtonsDisabled: boolean;
  isClockRunning: boolean;
  isTimeZero: boolean;
  endQuarterButtonDisabled: boolean;
  clockEventHandlers: {
    pauseStart: () => void;
    updateTime: (operation: string) => void;
    endQuarter: () => void;
  };
  pushEvent: (event: string, payload: any) => void;
  buttonPauseStart: React.RefObject<HTMLButtonElement>;
}

interface EndGameClockControlsProps {
  clockButtonsDisabled: boolean;
  clockEventHandlers: {
    endGame: () => void;
  };
}

function formatTime(time: number) {
  const minutes = Math.floor(time / 60);
  const seconds = time % 60;
  const minutesStr = minutes < 10 ? `0${minutes}` : minutes;
  const secondsStr = seconds < 10 ? `0${seconds}` : seconds;
  return `${minutesStr}:${secondsStr}`;
}

const TimeoutButton = ({ teamType, disabled, pushEvent }) => (
  <button
    className="button is-info"
    onClick={() =>
      pushEvent('update-team-stat', {
        'stat-id': 'timeouts',
        'team-type': teamType,
        operation: 'increment',
      })
    }
    disabled={disabled}
  >
    Timeout
  </button>
);

const TimeControl = ({ label, tooltip, onClick, disabled }) => (
  <button
    className="button is-info has-tooltip"
    data-tooltip={tooltip}
    onClick={onClick}
    disabled={disabled}
    aria-label={label}
  >
    {label}
  </button>
);

function InGameClockControls({
  clock_state,
  clockButtonsDisabled,
  isClockRunning,
  isTimeZero,
  endQuarterButtonDisabled,
  clockEventHandlers,
  pushEvent,
  buttonPauseStart,
}: InGameClockControlsProps) {
  return (
    <div className="columns is-multiline">
      <div className="column is-4">
        <TimeoutButton
          teamType="away"
          disabled={clockButtonsDisabled}
          pushEvent={pushEvent}
        />
      </div>

      <div className="column is-4">
        <span className="chip-label">{clock_state.period}</span>
      </div>

      <div className="column is-4">
        <TimeoutButton
          teamType="home"
          disabled={clockButtonsDisabled}
          pushEvent={pushEvent}
        />
      </div>

      <div className="column is-2">
        <TimeControl
          label="<<"
          tooltip="- 1 Min"
          onClick={() => clockEventHandlers.updateTime('increment60')}
          disabled={clockButtonsDisabled}
        />
      </div>
      <div className="column is-2">
        <TimeControl
          label="<"
          tooltip="- 1 Sec"
          onClick={() => clockEventHandlers.updateTime('increment')}
          disabled={clockButtonsDisabled}
        />
      </div>
      <div className="column is-4">
        <span className="chip-label">{formatTime(clock_state.time)}</span>
      </div>
      <div className="column is-2">
        <TimeControl
          label=">"
          tooltip="+ 1 Sec"
          onClick={() => clockEventHandlers.updateTime('decrement')}
          disabled={clockButtonsDisabled}
        />
      </div>
      <div className="column is-2">
        <TimeControl
          label=">>"
          tooltip="+ 1 Min"
          onClick={() => clockEventHandlers.updateTime('decrement60')}
          disabled={clockButtonsDisabled}
        />
      </div>

      <div className="column is-12">
        {isTimeZero ? (
          <button
            className="button is-warning is-fullwidth"
            onClick={clockEventHandlers.endQuarter}
            disabled={endQuarterButtonDisabled}
          >
            End quarter
          </button>
        ) : (
          <button
            ref={buttonPauseStart}
            className="button is-info is-fullwidth"
            onClick={clockEventHandlers.pauseStart}
            disabled={clockButtonsDisabled}
          >
            <span className="shortcut">SPACE</span>
            {isClockRunning ? 'Pause' : 'Start'}
          </button>
        )}
      </div>
    </div>
  );
}

function EndGameClockControls({
  clockButtonsDisabled,
  clockEventHandlers,
}: EndGameClockControlsProps) {
  return (
    <div className="columns is-multiline">
      <div className="column is-12">
        <button
          className="button is-danger is-fullwidth"
          onClick={clockEventHandlers.endGame}
          disabled={clockButtonsDisabled}
          style={{ height: '173px' }}
        >
          End Game
        </button>
      </div>
    </div>
  );
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
  const endQuarterButtonDisabled = clock_state.period >= 4 && !isGameTied;
  const isClockRunning = clock_state.state === 'running';
  const isTimeZero = clock_state.time === 0;
  const displayEndGameControls =
    clock_state.period >= 4 && !isGameTied && isTimeZero;

  // Event handlers
  const clockEventHandlers = {
    pauseStart: () => {
      const newState = isClockRunning ? 'paused' : 'running';
      pushEvent('update-clock-state', { state: newState });
    },

    updateTime: (operation: string) => {
      pushEvent('update-clock-time-and-period', {
        property: 'time',
        operation,
      });
    },

    endQuarter: () => {
      pushEvent('end-period', {});
    },

    endGame: () => {
      pushEvent('end-game', {});
    },
  };

  React.useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === ' ') {
        event.preventDefault();
        invokeButtonClickRef(buttonPauseStart);
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <div className="controls">
      {displayEndGameControls ? (
        <EndGameClockControls
          clockButtonsDisabled={clockButtonsDisabled}
          clockEventHandlers={{ endGame: clockEventHandlers.endGame }}
        />
      ) : (
        <InGameClockControls
          clock_state={clock_state}
          clockButtonsDisabled={clockButtonsDisabled}
          isClockRunning={isClockRunning}
          isTimeZero={isTimeZero}
          endQuarterButtonDisabled={endQuarterButtonDisabled}
          clockEventHandlers={{
            pauseStart: clockEventHandlers.pauseStart,
            updateTime: clockEventHandlers.updateTime,
            endQuarter: clockEventHandlers.endQuarter,
          }}
          pushEvent={pushEvent}
          buttonPauseStart={buttonPauseStart}
        />
      )}
    </div>
  );
}

export default ClockControls;
