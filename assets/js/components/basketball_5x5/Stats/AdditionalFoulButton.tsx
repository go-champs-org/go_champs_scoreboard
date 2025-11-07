import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';
import PlayerFoulsPanel from './PlayerFoulsPanel';
import CoachFoulsPanel from './CoachFoulsPanel';

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

  const popUpPanel = (panelRef: { close: () => void }) => {
    if (type === 'player') {
      return (
        <PlayerFoulsPanel
          panelRef={panelRef}
          onFoulWithoutFreeThrows={handleFoulWithoutFreeThrows}
          onFoulWithFreeThrows={handleFoulWithFreeThrows}
        />
      );
    } else {
      return (
        <CoachFoulsPanel
          panelRef={panelRef}
          onFoulWithoutFreeThrows={handleFoulWithoutFreeThrows}
          onFoulWithFreeThrows={handleFoulWithFreeThrows}
        />
      );
    }
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
