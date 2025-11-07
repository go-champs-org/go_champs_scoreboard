import React from 'react';

interface PlayerFoulsPanelProps {
  panelRef: { close: () => void };
  onFoulWithoutFreeThrows: (foulType: string, closePanel: () => void) => void;
  onFoulWithFreeThrows: (
    foulType: string,
    freeThrows: string,
    closePanel: () => void,
  ) => void;
}

function PlayerFoulsPanel({
  panelRef,
  onFoulWithoutFreeThrows,
  onFoulWithFreeThrows,
}: PlayerFoulsPanelProps) {
  return (
    <div className="additional-foul-button-pop-up-panel columns">
      <div className="column">
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            onFoulWithoutFreeThrows('fouls_unsportsmanlike', panelRef.close)
          }
        >
          U
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', '1', panelRef.close)
          }
        >
          U1
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', '2', panelRef.close)
          }
        >
          U2
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            onFoulWithFreeThrows('fouls_unsportsmanlike', '3', panelRef.close)
          }
        >
          U3
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
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
          onClick={() =>
            onFoulWithoutFreeThrows('fouls_disqualifying', panelRef.close)
          }
        >
          D
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', '1', panelRef.close)
          }
        >
          D1
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', '2', panelRef.close)
          }
        >
          D2
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
          onClick={() =>
            onFoulWithFreeThrows('fouls_disqualifying', '3', panelRef.close)
          }
        >
          D3
        </button>
        <button
          className="button is-fullwidth is-small is-danger"
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
        <button
          className="button is-fullwidth is-small is-black"
          onClick={() =>
            onFoulWithoutFreeThrows('fouls_game_disqualifying', panelRef.close)
          }
        >
          GD
        </button>
      </div>
    </div>
  );
}

export default PlayerFoulsPanel;
