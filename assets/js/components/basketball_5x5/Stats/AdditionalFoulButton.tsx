import React from 'react';
import { useTranslation } from 'react-i18next';
import PopUpButton from '../../PopUpButton';
import { useRulesVersion } from '../../../shared/ViewSettingsContext';
import PlayerFoulsPanel from './PlayerFoulsPanel';
import Fiba2026PlayerFoulsPanel from './Fiba2026PlayerFoulsPanel';
import CoachFoulsPanel from './CoachFoulsPanel';
import Fiba2026CoachFoulsPanel from './Fiba2026CoachFoulsPanel';

interface AdditionalFoulButtonProps {
  type: 'player' | 'coach';
  disabled: boolean;
  label: string;
  shortcut: string;
  /** Disable U fouls (DI and FL under fiba-2026) in the panel (player is not playing) */
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
  const rulesVersion = useRulesVersion();

  const handleQuickClick = () => {
    // Default action for quick click
    if (type === 'player') {
      onStatUpdate(
        rulesVersion === 'fiba-2026'
          ? 'fouls_disruptive'
          : 'fouls_unsportsmanlike',
      );
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

  const handleFoul = (
    foulType: string,
    metadata: Record<string, string | number> | undefined,
    closePanel: () => void,
  ) => {
    onStatUpdate(foulType, metadata);
    closePanel();
  };

  const popUpPanel = (
    panelRef: { close: () => void },
    firstButtonRef: React.RefObject<HTMLButtonElement | null>,
  ) => {
    if (type === 'player' && rulesVersion === 'fiba-2026') {
      return (
        <Fiba2026PlayerFoulsPanel
          panelRef={panelRef}
          onFoulWithoutFreeThrows={handleFoulWithoutFreeThrows}
          onFoulWithFreeThrows={handleFoulWithFreeThrows}
          firstButtonRef={firstButtonRef}
          disableOnCourtFouls={disablePlayerUnsportsmanlike}
          disableDisqualifying={disablePlayerDisqualifying}
        />
      );
    } else if (type === 'player') {
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
    } else if (rulesVersion === 'fiba-2026') {
      return (
        <Fiba2026CoachFoulsPanel
          panelRef={panelRef}
          onFoul={handleFoul}
          firstButtonRef={firstButtonRef}
          disableDisqualifying={disableCoachDisqualifying}
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
