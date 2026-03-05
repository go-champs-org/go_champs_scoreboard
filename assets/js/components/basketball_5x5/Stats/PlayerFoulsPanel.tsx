import React from 'react';

interface PlayerFoulsPanelProps {
  panelRef: { close: () => void };
  onFoulWithoutFreeThrows: (foulType: string, closePanel: () => void) => void;
  onFoulWithFreeThrows: (
    foulType: string,
    freeThrows: string,
    closePanel: () => void,
  ) => void;
  firstButtonRef: React.RefObject<HTMLButtonElement | null>;
  /** Disable U1/U2/U3/UC buttons (player is not playing) */
  disableUnsportsmanlike?: boolean;
  /** Disable D/D1/D2/D3/DC buttons (player already has a disqualifying foul) */
  disableDisqualifying?: boolean;
}

function PlayerFoulsPanel({
  panelRef,
  onFoulWithoutFreeThrows,
  onFoulWithFreeThrows,
  firstButtonRef,
  disableUnsportsmanlike = false,
  disableDisqualifying = false,
}: PlayerFoulsPanelProps) {
  return (
    <div className="additional-foul-button-pop-up-panel columns">
      <div className="column">
        <button
          className="button is-fullwidth is-small is-warning"
          disabled={disableUnsportsmanlike}
          ref={firstButtonRef}
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', '1', panelRef.close)
          }
        >
          U1
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          disabled={disableUnsportsmanlike}
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', '2', panelRef.close)
          }
        >
          U2
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          disabled={disableUnsportsmanlike}
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', '3', panelRef.close)
          }
        >
          U3
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          disabled={disableUnsportsmanlike}
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', 'C', panelRef.close)
          }
        >
          UC
        </button>
      </div>
      <div className="column">
        <button
          className="button is-fullwidth is-small is-danger"
          disabled={disableDisqualifying}
          onClick={() =>
            onFoulWithoutFreeThrows('fouls_disqualifying', panelRef.close)
          }
        >
          D
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          disabled={disableDisqualifying}
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', '1', panelRef.close)
          }
        >
          D1
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          disabled={disableDisqualifying}
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', '2', panelRef.close)
          }
        >
          D2
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          disabled={disableDisqualifying}
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', '3', panelRef.close)
          }
        >
          D3
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          disabled={disableDisqualifying}
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', 'C', panelRef.close)
          }
        >
          DC
        </button>
      </div>
      <div className="column">
        <button
          className="button is-fullwidth is-small is-dark"
          onClick={() =>
            onFoulWithoutFreeThrows(
              'fouls_disqualifying_fighting',
              panelRef.close,
            )
          }
        >
          F
        </button>
      </div>
    </div>
  );
}

export default PlayerFoulsPanel;
