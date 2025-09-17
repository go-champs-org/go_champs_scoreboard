import React from 'react';
import { PlayerSelection } from './Main';
import debounce from '../../debounce';
import { invokeButtonClickRef } from '../../shared/invokeButtonClick';
import { LiveState } from '../../types';
import { useTranslation } from '../../hooks/useTranslation';
import FoulButton from './Stats/FoulButton';

interface StatsControlsProps {
  pushEvent: (event: string, payload: any) => void;
  playerSelection: PlayerSelection;
  selectPlayer: (playerSelection: PlayerSelection | null) => void;
  liveState: LiveState;
  onShowFoulsModal: () => void;
}

// Custom hook for stat update logic
function useStatUpdate(
  pushEvent: (event: string, payload: any) => void,
  playerSelection: PlayerSelection,
  selectPlayer: (playerSelection: PlayerSelection | null) => void,
) {
  return React.useMemo(
    () =>
      debounce<(stat: string, metadata?: any) => void>((stat, metadata) => {
        pushEvent('update-player-stat', {
          ['stat-id']: stat,
          operation: 'increment',
          ['player-id']: playerSelection.playerId,
          ['team-type']: playerSelection.teamType,
          ...(metadata && { metadata }),
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
      const isModalOpen = document.querySelector('.modal.is-active') !== null;
      if (isModalOpen) return;

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
  onShowFoulsModal,
}: StatsControlsProps) {
  const { t } = useTranslation();
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
            className="button is-stat is-success"
            onClick={() => onStatUpdate('free_throws_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">1</span>
            {t('basketball.stats.controls.onePt')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['2']}
            className="button is-stat is-success"
            onClick={() => onStatUpdate('field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">2</span>
            {t('basketball.stats.controls.twoPts')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['3']}
            className="button is-stat is-success"
            onClick={() => onStatUpdate('three_point_field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">3</span>
            {t('basketball.stats.controls.threePts')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.q}
            className="button is-stat is-danger"
            onClick={() => onStatUpdate('free_throws_missed')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">Q</span>
            {t('basketball.stats.controls.missOnePt')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.w}
            className="button is-stat is-danger"
            onClick={() => onStatUpdate('field_goals_missed')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">W</span>
            {t('basketball.stats.controls.missTwoPts')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.e}
            className="button is-stat is-danger"
            onClick={() => onStatUpdate('three_point_field_goals_missed')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">E</span>
            {t('basketball.stats.controls.missThreePts')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.a}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('rebounds_offensive')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">A</span>
            {t('basketball.stats.controls.oneRebOff')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.s}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('steals')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">S</span>
            {t('basketball.stats.controls.oneStl')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.d}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('rebounds_defensive')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">D</span>
            {t('basketball.stats.controls.oneRebDef')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.z}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('assists')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">Z</span>
            {t('basketball.stats.controls.oneAss')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.x}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('blocks')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">X</span>
            {t('basketball.stats.controls.oneBlk')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.c}
            className="button is-stat is-danger"
            onClick={() => onStatUpdate('turnovers')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">C</span>
            {t('basketball.stats.controls.oneTo')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <FoulButton
            statId="fouls_personal"
            disabled={buttonsDisabled}
            label={t('basketball.stats.controls.personalFoul')}
            shortcut="T"
            onStatUpdate={onStatUpdate}
          />
        </div>
        <div className="column is-4 has-text-centered">
          <FoulButton
            statId="fouls_technical"
            disabled={buttonsDisabled}
            label={t('basketball.stats.controls.technicalFoul')}
            shortcut="G"
            onStatUpdate={onStatUpdate}
          />
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs.b}
            className="button is-stat is-warning"
            onClick={() => onShowFoulsModal()}
            disabled={liveState.state !== 'in_progress'}
          >
            <span className="shortcut">B</span>
            {t('basketball.stats.controls.moreFouls')}
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
  onShowFoulsModal = () => {},
}: StatsControlsProps) {
  const { t } = useTranslation();
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
            className="button is-stat is-success"
            onClick={() => onStatUpdate('free_throws_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">1</span>
            {t('basketball.stats.controls.onePt')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['2']}
            className="button is-stat is-success"
            onClick={() => onStatUpdate('field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">2</span>
            {t('basketball.stats.controls.twoPts')}
          </button>
        </div>
        <div className="column is-4 has-text-centered">
          <button
            ref={buttonRefs['3']}
            className="button is-stat is-success"
            onClick={() => onStatUpdate('three_point_field_goals_made')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">3</span>
            {t('basketball.stats.controls.threePts')}
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.q}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('rebounds_defensive')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">q</span>
            {t('basketball.stats.controls.oneReb')}
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.w}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('assists')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">w</span>
            {t('basketball.stats.controls.oneAss')}
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.a}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('blocks')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">a</span>
            {t('basketball.stats.controls.oneBlk')}
          </button>
        </div>
        <div className="column is-6 has-text-centered">
          <button
            ref={buttonRefs.s}
            className="button is-stat is-info"
            onClick={() => onStatUpdate('steals')}
            disabled={buttonsDisabled}
          >
            <span className="shortcut">s</span>
            {t('basketball.stats.controls.oneStl')}
          </button>
        </div>
      </div>
    </div>
  );
}

export default MediumStatsControls;
