import React from 'react';
import { PlayerSelection } from './Main';
import debounce from '../../debounce';
import { invokeButtonClickRef } from '../../shared/invokeButtonClick';
import { LiveState } from '../../types';

interface StatsControlsProps {
  pushEvent: (event: string, payload: any) => void;
  playerSelection: PlayerSelection;
  selectPlayer: (playerSelection: PlayerSelection | null) => void;
  liveState: LiveState;
}

// Custom hook for stat update logic
function useStatUpdate(
  pushEvent: (event: string, payload: any) => void,
  playerSelection: PlayerSelection,
  selectPlayer: (playerSelection: PlayerSelection | null) => void,
) {
  return React.useMemo(
    () =>
      debounce<(stat: string) => void>((stat) => {
        pushEvent('update-player-stat', {
          ['stat-id']: stat,
          operation: 'increment',
          ['player-id']: playerSelection.playerId,
          ['team-type']: playerSelection.teamType,
        });
        selectPlayer(null);
      }, 100),
    [pushEvent, playerSelection, selectPlayer],
  );
}

// Custom hook for keyboard listeners
function useKeyboardShortcuts(
  buttonRefs: Record<string, React.RefObject<HTMLButtonElement>>,
  selectPlayer: (playerSelection: PlayerSelection | null) => void,
) {
  React.useEffect(() => {
    const listener = (event: KeyboardEvent) => {
      const { key } = event;
      if (key === 'Escape') {
        selectPlayer(null);
      } else if (key in buttonRefs) {
        invokeButtonClickRef(buttonRefs[key as keyof typeof buttonRefs]);
      }
    };

    document.addEventListener('keydown', listener);
    return () => document.removeEventListener('keydown', listener);
  }, [selectPlayer, buttonRefs]);
}

// Custom hook for buttons disabled state
function useButtonsDisabled(
  liveState: LiveState,
  playerSelection: PlayerSelection,
) {
  return React.useMemo(
    () => liveState.state !== 'in_progress' || playerSelection === null,
    [liveState.state, playerSelection],
  );
}

export function MediumStatsControls({
  pushEvent,
  playerSelection,
  selectPlayer,
  liveState,
}: StatsControlsProps) {
  const buttonRefs = {
    '1': React.useRef<HTMLButtonElement>(null),
    '2': React.useRef<HTMLButtonElement>(null),
    '3': React.useRef<HTMLButtonElement>(null),
    q: React.useRef<HTMLButtonElement>(null),
    w: React.useRef<HTMLButtonElement>(null),
    e: React.useRef<HTMLButtonElement>(null),
    a: React.useRef<HTMLButtonElement>(null),
    s: React.useRef<HTMLButtonElement>(null),
    d: React.useRef<HTMLButtonElement>(null),
    z: React.useRef<HTMLButtonElement>(null),
    x: React.useRef<HTMLButtonElement>(null),
    c: React.useRef<HTMLButtonElement>(null),
    t: React.useRef<HTMLButtonElement>(null),
    g: React.useRef<HTMLButtonElement>(null),
    b: React.useRef<HTMLButtonElement>(null),
  };

  const onStatUpdate = useStatUpdate(pushEvent, playerSelection, selectPlayer);
  useKeyboardShortcuts(buttonRefs, selectPlayer);
  const buttonsDisabled = useButtonsDisabled(liveState, playerSelection);
  return (
    <div className="controls">
      <div className="columns is-multiline">
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['1']}
            className="button is-tall is-success"
            onClick={() => onStatUpdate('free_throws_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">1</span>
            +1 PT
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['2']}
            className="button is-tall is-success"
            onClick={() => onStatUpdate('field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">2</span>
            +2 PTS
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['3']}
            className="button is-tall is-success"
            onClick={() => onStatUpdate('three_point_field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">3</span>
            +3 PTS
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.q}
            className="button is-tall is-danger"
            onClick={() => onStatUpdate('free_throws_missed')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">Q</span>
            Miss 1 PT
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.w}
            className="button is-tall is-danger"
            onClick={() => onStatUpdate('field_goals_missed')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">W</span>
            Miss 2 PTS
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.e}
            className="button is-tall is-danger"
            onClick={() => onStatUpdate('three_point_field_goals_missed')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">E</span>
            Miss 3 PTS
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.a}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('rebounds_offensive')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">A</span>
            +1 REB OFF
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.s}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('steals')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">S</span>
            +1 STL
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.d}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('rebounds_defensive')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">D</span>
            +1 REB DEF
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.z}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('assists')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">Z</span>
            +1 ASS
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.x}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('blocks')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">X</span>
            +1 BLK
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.c}
            className="button is-tall is-danger"
            onClick={() => onStatUpdate('turnovers')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">C</span>
            +1 TO
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.t}
            className="button is-tall is-warning"
            onClick={() => onStatUpdate('fouls_personal')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">T</span>
            Personal Fault
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.g}
            className="button is-tall is-warning"
            onClick={() => onStatUpdate('fouls_technical')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">G</span>
            Technical Fault
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.b}
            className="button is-tall is-warning"
            onClick={() => onStatUpdate('fouls_flagrant')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">B</span>
            Flagrant Fault
          </button>
        </div>
      </div>
    </div>
  );
}

export function BasicStatsControls({
  pushEvent,
  playerSelection,
  selectPlayer,
  liveState,
}: StatsControlsProps) {
  const buttonRefs = {
    '1': React.useRef<HTMLButtonElement>(null),
    '2': React.useRef<HTMLButtonElement>(null),
    '3': React.useRef<HTMLButtonElement>(null),
    q: React.useRef<HTMLButtonElement>(null),
    w: React.useRef<HTMLButtonElement>(null),
    a: React.useRef<HTMLButtonElement>(null),
    s: React.useRef<HTMLButtonElement>(null),
  };

  const onStatUpdate = useStatUpdate(pushEvent, playerSelection, selectPlayer);
  useKeyboardShortcuts(buttonRefs, selectPlayer);
  const buttonsDisabled = useButtonsDisabled(liveState, playerSelection);
  return (
    <div className="controls">
      <div className="columns is-multiline">
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['1']}
            className="button is-tall is-success"
            onClick={() => onStatUpdate('free_throws_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">1</span>
            +1 PT
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['2']}
            className="button is-tall is-success"
            onClick={() => onStatUpdate('field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">2</span>
            +2 PTS
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['3']}
            className="button is-tall is-success"
            onClick={() => onStatUpdate('three_point_field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">3</span>
            +3 PTS
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.q}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('rebounds_defensive')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">q</span>
            +1 REB
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.w}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('assists')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">w</span>
            +1 ASS
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.a}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('blocks')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">a</span>
            +1 BLK
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.s}
            className="button is-tall is-info"
            onClick={() => onStatUpdate('steals')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">s</span>
            +1 STL
          </button>
        </div>
      </div>
    </div>
  );
}

export default MediumStatsControls;
