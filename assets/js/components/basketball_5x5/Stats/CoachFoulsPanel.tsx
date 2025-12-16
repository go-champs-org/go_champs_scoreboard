import React from 'react';

interface CoachFoulsPanelProps {
  panelRef: { close: () => void };
  onFoulWithoutFreeThrows: (foulType: string, closePanel: () => void) => void;
  onFoulWithFreeThrows: (
    foulType: string,
    freeThrows: string,
    closePanel: () => void,
  ) => void;
  firstButtonRef: React.RefObject<HTMLButtonElement | null>;
}

function CoachFoulsPanel({
  panelRef,
  onFoulWithoutFreeThrows,
  onFoulWithFreeThrows,
  firstButtonRef,
}: CoachFoulsPanelProps) {
  return (
    <div className="additional-foul-button-pop-up-panel columns">
      <div className="column">
        <button
          className="button is-fullwidth is-small is-warning"
          ref={firstButtonRef}
          onClick={() =>
            onFoulWithFreeThrows('fouls_technical', '1', panelRef.close)
          }
        >
          C1
        </button>
        <button
          className="button is-fullwidth is-small is-warning"
          onClick={() =>
            onFoulWithFreeThrows('fouls_technical', 'C', panelRef.close)
          }
        >
          CC
        </button>
      </div>
      <div className="column">
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            onFoulWithoutFreeThrows('fouls_technical_bench', panelRef.close)
          }
        >
          B
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            onFoulWithFreeThrows('fouls_technical_bench', '1', panelRef.close)
          }
        >
          B1
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            onFoulWithFreeThrows('fouls_technical_bench', '2', panelRef.close)
          }
        >
          B2
        </button>
        <button
          className="button is-fullwidth is-small is-info"
          onClick={() =>
            onFoulWithFreeThrows('fouls_technical_bench', 'C', panelRef.close)
          }
        >
          BC
        </button>
      </div>
      <div className="column">
        <button
          className="button is-fullwidth is-small is-primary"
          onClick={() =>
            onFoulWithoutFreeThrows(
              'fouls_technical_bench_disqualifying',
              panelRef.close,
            )
          }
        >
          <span
            style={{
              border: '1px solid black',
              borderRadius: '50px',
              padding: '0 5px',
              margin: '-1px 0',
            }}
          >
            B
          </span>
        </button>
        <button
          className="button is-fullwidth is-small is-primary"
          onClick={() =>
            onFoulWithFreeThrows(
              'fouls_technical_bench_disqualifying',
              '2',
              panelRef.close,
            )
          }
        >
          <span
            style={{
              border: '1px solid black',
              borderRadius: '50px',
              padding: '0 2px',
              margin: '-1px 0',
            }}
          >
            B2
          </span>
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

export default CoachFoulsPanel;
