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
  /** Disable U fouls in the panel (player is not playing) */
  disablePlayerUnsportsmanlike?: boolean;
  /** Disable D fouls in the panel (player already has a disqualifying foul) */
  disablePlayerDisqualifying?: boolean;
  /** Disable all non-F coach fouls in the panel (coach already has a disqualifying foul) */
  disableCoachDisqualifying?: boolean;
  onStatUpdate: (stat: string, metadata?: any) => void;
}

function AdditionalFoulButton({
  type,
  disabled,
  label,
  shortcut,
  disablePlayerUnsportsmanlike = false,
  disablePlayerDisqualifying = false,
  disableCoachDisqualifying = false,
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

  const popUpPanel = (
    panelRef: { close: () => void },
    firstButtonRef: React.RefObject<HTMLButtonElement | null>,
  ) => {
    if (type === 'player') {
      return (
        <PlayerFoulsPanel
          panelRef={panelRef}
          onFoulWithoutFreeThrows={handleFoulWithoutFreeThrows}
          onFoulWithFreeThrows={handleFoulWithFreeThrows}
          firstButtonRef={firstButtonRef}
          disableUnsportsmanlike={disablePlayerUnsportsmanlike}
          disableDisqualifying={disablePlayerDisqualifying}
        />
      );
    } else {
      return (
        <CoachFoulsPanel
          panelRef={panelRef}
          onFoulWithoutFreeThrows={handleFoulWithoutFreeThrows}
          onFoulWithFreeThrows={handleFoulWithFreeThrows}
          firstButtonRef={firstButtonRef}
          disableDisqualifying={disableCoachDisqualifying}
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
