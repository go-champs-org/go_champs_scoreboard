import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';

interface PlayerAdditionalFoulButtonProps {
  disabled: boolean;
  label: string;
  shortcut: string;
  onStatUpdate: (stat: string, metadata?: any) => void;
}

function PlayerAdditionalFoulButton({
  disabled,
  label,
  shortcut,
  onStatUpdate,
}: PlayerAdditionalFoulButtonProps) {
  const { t } = useTranslation();

  const handleQuickClick = () => {
    // Default action for quick click - could be most common foul
    onStatUpdate('fouls_unsportsmanlike');
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

  const popUpPanel = (panelRef: { close: () => void }) => (
    <div className="player-additional-foul-button-pop-up-panel">
      <div>
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
      <div>
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

export default PlayerAdditionalFoulButton;
