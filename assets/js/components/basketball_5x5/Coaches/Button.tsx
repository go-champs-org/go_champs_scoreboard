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
  const fouls = coach?.stats_values['fouls'] || 0;
  const isDisqualified = coach?.state === 'disqualified';
  const isDisabled =
    liveState.state === LiveStateStates.NOT_STARTED || !coach || isDisqualified; // Disable if no coach exists or is disqualified
  const [isAnimating, setIsAnimating] = React.useState(false);
  const previousFouls = React.useRef(fouls);

  // Trigger animation when fouls value changes
  React.useEffect(() => {
    if (fouls !== previousFouls.current && fouls > 0) {
      setIsAnimating(true);
      const timer = setTimeout(() => {
        setIsAnimating(false);
      }, 1000); // 1 second animation

      return () => clearTimeout(timer);
    }
    previousFouls.current = fouls;
  }, [fouls]);

  const getCoachLabel = () => {
    const typeKey =
      coachType === 'head_coach'
        ? 'basketball.coaches.types.headCoachShort'
        : 'basketball.coaches.types.assistantCoachShort';

    return t(typeKey).toUpperCase();
  };

  return (
    <button
      className={`coach-button button ${isSelected ? 'is-dark' : ''} ${
        isDisqualified ? 'is-disqualified has-tooltip' : ''
      }`}
      data-tooltip={
        isDisqualified ? t('basketball.coaches.disqualified') : undefined
      }
      disabled={isDisabled}
      onClick={onClick}
      title={coach ? coach.name : `No ${coachType.replace('_', ' ')} assigned`}
    >
      <div className="content">
        {getCoachLabel()}
        {fouls > 0 && (
          <span className={`fouls ${isAnimating ? 'fouls-animate' : ''}`}>
            {fouls}
          </span>
        )}
      </div>
    </button>
  );
}

export default CoachButton;
