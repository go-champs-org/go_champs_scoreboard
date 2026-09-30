import React from 'react';
import FoulLetter from './FoulLetter';

interface Fiba2026PlayerFoulsPanelProps {
  panelRef: { close: () => void };
  onFoulWithoutFreeThrows: (foulType: string, closePanel: () => void) => void;
  onFoulWithFreeThrows: (
    foulType: string,
    freeThrows: string,
    closePanel: () => void,
  ) => void;
  firstButtonRef: React.RefObject<HTMLButtonElement | null>;
  /** Disable DI and FL buttons (player is not playing) */
  disableOnCourtFouls?: boolean;
  /** Disable D/D1/D2/D3/DC buttons (player already has a disqualifying foul) */
  disableDisqualifying?: boolean;
}

interface FoulColumn {
  statId: string;
  letter: string;
  isCircled: boolean;
  className: string;
  /** null registers the foul without free throws */
  options: (string | null)[];
  disabled: boolean;
}

function Fiba2026PlayerFoulsPanel({
  panelRef,
  onFoulWithoutFreeThrows,
  onFoulWithFreeThrows,
  firstButtonRef,
  disableOnCourtFouls = false,
  disableDisqualifying = false,
}: Fiba2026PlayerFoulsPanelProps) {
  const columns: FoulColumn[] = [
    {
      statId: 'fouls_disruptive',
      letter: 'DI',
      isCircled: false,
      className: 'is-info',
      options: [null, '1', '2', '3', 'C'],
      disabled: disableOnCourtFouls,
    },
    {
      statId: 'fouls_flagrant',
      letter: 'FL',
      isCircled: true,
      className: 'is-primary',
      options: [null, '1', '2', '3', 'C'],
      disabled: disableOnCourtFouls,
    },
    {
      statId: 'fouls_disqualifying',
      letter: 'D',
      isCircled: false,
      className: 'is-danger',
      options: [null, '1', '2', '3', 'C'],
      disabled: disableDisqualifying,
    },
    {
      statId: 'fouls_disqualifying_fighting',
      letter: 'F',
      isCircled: false,
      className: 'is-dark',
      options: [null],
      disabled: false,
    },
  ];

  return (
    <div className="additional-foul-button-pop-up-panel columns">
      {columns.map((column, columnIndex) => (
        <div className="column" key={column.statId}>
          {column.options.map((freeThrows, optionIndex) => (
            <button
              key={freeThrows ?? 'none'}
              className={`button is-fullwidth is-small ${column.className}`}
              disabled={column.disabled}
              ref={
                columnIndex === 0 && optionIndex === 0
                  ? firstButtonRef
                  : undefined
              }
              onClick={() =>
                freeThrows === null
                  ? onFoulWithoutFreeThrows(column.statId, panelRef.close)
                  : onFoulWithFreeThrows(
                      column.statId,
                      freeThrows,
                      panelRef.close,
                    )
              }
            >
              <FoulLetter
                letter={column.letter}
                isCircled={column.isCircled}
                suffix={freeThrows ?? ''}
              />
            </button>
          ))}
        </div>
      ))}
    </div>
  );
}

export default Fiba2026PlayerFoulsPanel;
