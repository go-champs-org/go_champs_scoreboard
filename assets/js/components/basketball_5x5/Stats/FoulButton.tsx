import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';

interface FoulButtonProps {
  statId: 'fouls_personal' | 'fouls_technical' | 'fouls_unsportsmanlike';
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

  const handleFreeThrowOption = (freeThrows: string) => {
    onStatUpdate(statId, {
      ['free-throws-awarded']: freeThrows,
    });
  };

  const popUpButtons = [
    {
      label: t('basketball.stats.controls.oneFreeThrow'),
      onClick: () => handleFreeThrowOption('1'),
    },
    {
      label: t('basketball.stats.controls.twoFreeThrows'),
      onClick: () => handleFreeThrowOption('2'),
    },
    {
      label: t('basketball.stats.controls.threeFreeThrows'),
      onClick: () => handleFreeThrowOption('3'),
    },
    {
      label: t('basketball.stats.controls.canceledFreeThrows'),
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
    >
      <span className="shortcut">{shortcut}</span>
      {label}
    </PopUpButton>
  );
}

export default FoulButton;
