import React from 'react';
import { CoachState, LiveStateStates, LiveState } from '../../../types';
import { t } from 'i18next';

interface CoachButtonProps {
  coach?: CoachState;
  coachType: 'head_coach' | 'assistant_coach';
  onClick: () => void;
  isSelected: boolean;
  liveState: LiveState;
}

function CoachButton({
  coach,
  coachType,
  onClick,
  isSelected,
  liveState,
}: CoachButtonProps) {
  const isDisabled = liveState.state === LiveStateStates.NOT_STARTED || !coach; // Disable if no coach exists

  const getCoachLabel = () => {
    const typeKey =
      coachType === 'head_coach'
        ? 'basketball.coaches.types.headCoachShort'
        : 'basketball.coaches.types.assistantCoachShort';

    return t(typeKey).toUpperCase();
  };

  return (
    <button
      className={`coach-button button ${isSelected ? 'is-dark' : ''}`}
      disabled={isDisabled}
      onClick={onClick}
      title={coach ? coach.name : `No ${coachType.replace('_', ' ')} assigned`}
    >
      {getCoachLabel()}
    </button>
  );
}

export default CoachButton;
