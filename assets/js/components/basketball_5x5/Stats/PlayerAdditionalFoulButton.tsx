import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';

interface AdditionalFoulButtonProps {
  type: 'player' | 'coach';
  disabled: boolean;
  label: string;
  shortcut: string;
  onStatUpdate: (stat: string, metadata?: any) => void;
}

function AdditionalFoulButton({
  type,
  disabled,
  label,
  shortcut,
  onStatUpdate,
}: AdditionalFoulButtonProps) {
  const { t } = useTranslation();

  const handleQuickClick = () => {
    // Default action for quick click
    if (type === 'player') {
      onStatUpdate('fouls_unsportsmanlike');
    } else {
      onStatUpdate('fouls_technical');
    }
  };

  const handleFoulWithoutFreeThrows = (
    foulType: string,
    closePanel: () => void,
  ) => {
    onStatUpdate(foulType);
    closePanel();
  };

  const handleFoulWithFreeThrows = (
    foulType: string,
    freeThrows: string,
    closePanel: () => void,
  ) => {
    onStatUpdate(foulType, {
      ['free-throws-awarded']: freeThrows,
    });
    closePanel();
  };

  const renderPlayerFouls = (panelRef: { close: () => void }) => (
    <div className="additional-foul-button-pop-up-panel columns">
      <div className="column">
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithoutFreeThrows('fouls_unsportsmanlike', panelRef.close)
          }
        >
          U
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_unsportsmanlike',
              '1',
              panelRef.close,
            )
          }
        >
          U1
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_unsportsmanlike',
              '2',
              panelRef.close,
            )
          }
        >
          U2
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_unsportsmanlike',
              '3',
              panelRef.close,
            )
          }
        >
          U3
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_unsportsmanlike',
              'C',
              panelRef.close,
            )
          }
        >
          UC
        </button>
        <button
          className="button is-fullwidth is-small is-dark"
          onClick={() =>
            handleFoulWithoutFreeThrows(
              'fouls_disqualifying_fighting',
              panelRef.close,
            )
          }
        >
          F
        </button>
      </div>
      <div className="column">
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithoutFreeThrows('fouls_disqualifying', panelRef.close)
          }
        >
          D
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', '1', panelRef.close)
          }
        >
          D1
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', '2', panelRef.close)
          }
        >
          D2
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', '3', panelRef.close)
          }
        >
          D3
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', 'C', panelRef.close)
          }
        >
          DC
        </button>
        <button
          className="button is-fullwidth is-small is-black"
          onClick={() =>
            handleFoulWithoutFreeThrows(
              'fouls_game_disqualifying',
              panelRef.close,
            )
          }
        >
          GD
        </button>
      </div>
    </div>
  );

  const renderCoachFouls = (panelRef: { close: () => void }) => (
    <div className="additional-foul-button-pop-up-panel">
      <div>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_technical', '1', panelRef.close)
          }
        >
          C1
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_technical', 'C', panelRef.close)
          }
        >
          CC
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            handleFoulWithoutFreeThrows('fouls_technical_bench', panelRef.close)
          }
        >
          B
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_technical_bench',
              '1',
              panelRef.close,
            )
          }
        >
          B1
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_technical_bench',
              '2',
              panelRef.close,
            )
          }
        >
          B2
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_technical_bench',
              'C',
              panelRef.close,
            )
          }
        >
          BC
        </button>
      </div>
      <div>
        <button
          className="button is-fullwidth is-small is-primary"
          onClick={() =>
            handleFoulWithoutFreeThrows(
              'fouls_technical_bench_disqualifying',
              panelRef.close,
            )
          }
        >
          BD
        </button>
        <button
          className="button is-fullwidth is-small is-primary"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_technical_bench_disqualifying',
              '1',
              panelRef.close,
            )
          }
        >
          BD1
        </button>
        <button
          className="button is-fullwidth is-small is-primary"
          onClick={() =>
            handleFoulWithFreeThrows(
              'fouls_technical_bench_disqualifying',
              '2',
              panelRef.close,
            )
          }
        >
          BD2
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithoutFreeThrows('fouls_disqualifying', panelRef.close)
          }
        >
          D
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', '1', panelRef.close)
          }
        >
          D1
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', '2', panelRef.close)
          }
        >
          D2
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            handleFoulWithFreeThrows('fouls_disqualifying', 'C', panelRef.close)
          }
        >
          DC
        </button>
        <button
          className="button is-fullwidth is-small is-dark"
          onClick={() =>
            handleFoulWithoutFreeThrows(
              'fouls_disqualifying_fighting',
              panelRef.close,
            )
          }
        >
          F
        </button>
        <button
          className="button is-fullwidth is-small is-black"
          onClick={() =>
            handleFoulWithoutFreeThrows(
              'fouls_game_disqualifying',
              panelRef.close,
            )
          }
        >
          GD
        </button>
      </div>
    </div>
  );

  const popUpPanel = (panelRef: { close: () => void }) => {
    return type === 'player'
      ? renderPlayerFouls(panelRef)
      : renderCoachFouls(panelRef);
  };

  return (
    <PopUpButton
      popUpPanel={popUpPanel}
      keyboardKey={shortcut.toLowerCase()}
      className="button is-stat is-warning"
      onQuickClick={handleQuickClick}
      holdDuration={0}
      disabled={disabled}
    >
      <span className="shortcut">{shortcut}</span>
      {label}
    </PopUpButton>
  );
}

export default AdditionalFoulButton;
