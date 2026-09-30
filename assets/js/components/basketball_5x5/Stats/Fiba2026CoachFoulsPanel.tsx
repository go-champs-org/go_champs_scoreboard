import React from 'react';
import FoulLetter from './FoulLetter';

interface Fiba2026CoachFoulsPanelProps {
  panelRef: { close: () => void };
  onFoul: (
    foulType: string,
    metadata: Record<string, string | number> | undefined,
    closePanel: () => void,
  ) => void;
  firstButtonRef: React.RefObject<HTMLButtonElement | null>;
  /** Disable all non-F buttons (coach already has a disqualifying foul) */
  disableDisqualifying?: boolean;
}

interface FoulOption {
  /** null registers the foul without free throws */
  freeThrows: string | null;
  /** Bench members disqualified in the same incident (BD without circle) */
  disqualifiedMembers?: number;
}

interface FoulColumn {
  statId: string;
  letter: string;
  isCircled: boolean;
  className: string;
  options: FoulOption[];
  disabled: boolean;
}

function optionsFor(freeThrows: (string | null)[]): FoulOption[] {
  return freeThrows.map((value) => ({ freeThrows: value }));
}

function Fiba2026CoachFoulsPanel({
  panelRef,
  onFoul,
  firstButtonRef,
  disableDisqualifying = false,
}: Fiba2026CoachFoulsPanelProps) {
  const columns: FoulColumn[] = [
    {
      statId: 'fouls_technical',
      letter: 'C',
      isCircled: true,
      className: 'is-warning',
      options: optionsFor(['1', 'C']),
      disabled: disableDisqualifying,
    },
    {
      statId: 'fouls_technical_bench',
      letter: 'B',
      isCircled: true,
      className: 'is-info',
      options: optionsFor([null, '1', '2', 'C']),
      disabled: disableDisqualifying,
    },
    {
      statId: 'fouls_technical_bench_disqualifying_circled',
      letter: 'BD',
      isCircled: true,
      className: 'is-primary',
      options: optionsFor([null, '2']),
      disabled: disableDisqualifying,
    },
    {
      statId: 'fouls_technical_bench_disqualifying',
      letter: 'BD',
      isCircled: false,
      className: 'is-link',
      options: [
        { freeThrows: null, disqualifiedMembers: 1 },
        { freeThrows: null, disqualifiedMembers: 2 },
        { freeThrows: '2', disqualifiedMembers: 1 },
        { freeThrows: '2', disqualifiedMembers: 2 },
      ],
      disabled: disableDisqualifying,
    },
    {
      statId: 'fouls_disqualifying',
      letter: 'D',
      isCircled: false,
      className: 'is-danger',
      options: optionsFor([null, '1', '2', 'C']),
      disabled: disableDisqualifying,
    },
    {
      statId: 'fouls_disqualifying_fighting',
      letter: 'F',
      isCircled: false,
      className: 'is-dark',
      options: optionsFor([null]),
      disabled: false,
    },
  ];

  const metadataFor = (option: FoulOption) => {
    const metadata: Record<string, string | number> = {};
    if (option.freeThrows !== null) {
      metadata['free-throws-awarded'] = option.freeThrows;
    }
    if (option.disqualifiedMembers !== undefined) {
      metadata['disqualified-members'] = option.disqualifiedMembers;
    }
    return Object.keys(metadata).length > 0 ? metadata : undefined;
  };

  return (
    <div className="additional-foul-button-pop-up-panel columns">
      {columns.map((column, columnIndex) => (
        <div className="column" key={column.statId}>
          {column.options.map((option, optionIndex) => (
            <button
              key={`${option.freeThrows ?? 'none'}-${
                option.disqualifiedMembers ?? 1
              }`}
              className={`button is-fullwidth is-small ${column.className}`}
              disabled={column.disabled}
              ref={
                columnIndex === 0 && optionIndex === 0
                  ? firstButtonRef
                  : undefined
              }
              onClick={() =>
                onFoul(column.statId, metadataFor(option), panelRef.close)
              }
            >
              <FoulLetter
                letter={column.letter}
                isCircled={column.isCircled}
                suffix={option.freeThrows ?? ''}
              />
              {option.disqualifiedMembers !== undefined && (
                <span className="disqualified-members">
                  ×{option.disqualifiedMembers}
                </span>
              )}
            </button>
          ))}
        </div>
      ))}
    </div>
  );
}

export default Fiba2026CoachFoulsPanel;
