import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';

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

  const handleQuickClick = () => {
    onStatUpdate(statId);
  };

  const handleFreeThrowOption = (freeThrows?: string) => {
    if (freeThrows) {
      onStatUpdate(statId, {
        ['free-throws-awarded']: freeThrows,
      });
    }
    onStatUpdate(statId);
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
            label: t('basketball.stats.controls.technicalFoulNoFreeThrow'),
            onClick: () => handleFreeThrowOption(),
          },
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

  return (
    <PopUpButton
      popUpButtons={popUpButtons}
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
