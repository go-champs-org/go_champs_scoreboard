import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';
import FoulLetter from './FoulLetter';
import { useRulesVersion } from '../../../shared/ViewSettingsContext';

interface FoulButtonProps {
  statId: 'fouls_personal' | 'fouls_technical';
  disabled: boolean;
  label: string;
  shortcut: string;
  onStatUpdate: (stat: string, metadata?: any) => void;
}

function FoulButton({
  statId,
  disabled,
  label,
  shortcut,
  onStatUpdate,
}: FoulButtonProps) {
  const { t } = useTranslation();
  const rulesVersion = useRulesVersion();

  const handleQuickClick = () => {
    onStatUpdate(statId);
  };

  const handleFreeThrowOption = (freeThrows?: string) => {
    if (freeThrows) {
      onStatUpdate(statId, {
        ['free-throws-awarded']: freeThrows,
      });
    } else {
      onStatUpdate(statId);
    }
  };

  const popUpButtons =
    statId === 'fouls_personal'
      ? [
          {
            label: t('basketball.stats.controls.personalFoulNoFreeThrow'),
            onClick: () => handleFreeThrowOption(),
          },
          {
            label: t('basketball.stats.controls.personalFoulOneFreeThrow'),
            onClick: () => handleFreeThrowOption('1'),
          },
          {
            label: t('basketball.stats.controls.personalFoulTwoFreeThrows'),
            onClick: () => handleFreeThrowOption('2'),
          },
          {
            label: t('basketball.stats.controls.personalFoulThreeFreeThrows'),
            onClick: () => handleFreeThrowOption('3'),
          },
          {
            label: t(
              'basketball.stats.controls.personalFoulCanceledFreeThrows',
            ),
            onClick: () => handleFreeThrowOption('C'),
          },
        ]
      : [
          {
            label: t('basketball.stats.controls.technicalFoulOneFreeThrow'),
            onClick: () => handleFreeThrowOption('1'),
          },
          {
            label: t(
              'basketball.stats.controls.technicalFoulCanceledFreeThrows',
            ),
            onClick: () => handleFreeThrowOption('C'),
          },
        ];

  // FIBA 2026: technical fouls are category 2 (T) or category 1 (circled T)
  const fiba2026TechnicalFoulsPanel = (panelRef: {
    close: () => void;
    firstButtonRef: React.RefObject<HTMLButtonElement | null>;
  }) => (
    <div className="additional-foul-button-pop-up-panel columns">
      {[
        { technicalStatId: 'fouls_technical', isCircled: false },
        { technicalStatId: 'fouls_technical_category_1', isCircled: true },
      ].map(({ technicalStatId, isCircled }, columnIndex) => (
        <div className="column" key={technicalStatId}>
          {['1', 'C'].map((freeThrows, optionIndex) => (
            <button
              key={freeThrows}
              className="button is-fullwidth is-small is-warning"
              ref={
                columnIndex === 0 && optionIndex === 0
                  ? panelRef.firstButtonRef
                  : undefined
              }
              onClick={() => {
                onStatUpdate(technicalStatId, {
                  ['free-throws-awarded']: freeThrows,
                });
                panelRef.close();
              }}
            >
              <FoulLetter
                letter="T"
                isCircled={isCircled}
                suffix={freeThrows}
              />
            </button>
          ))}
        </div>
      ))}
    </div>
  );

  const isFiba2026TechnicalFoul =
    statId === 'fouls_technical' && rulesVersion === 'fiba-2026';

  return (
    <PopUpButton
      popUpPanel={
        isFiba2026TechnicalFoul ? fiba2026TechnicalFoulsPanel : undefined
      }
      popUpButtons={isFiba2026TechnicalFoul ? [] : popUpButtons}
      keyboardKey={shortcut.toLowerCase()}
      className="button is-stat is-warning"
      onQuickClick={handleQuickClick}
      disabled={disabled}
      holdDuration={0}
    >
      <span className="shortcut">{shortcut}</span>
      {label}
    </PopUpButton>
  );
}

export default FoulButton;
