import React from 'react';
import { PlayerState, TeamState } from '../../../types';
import { useTranslation } from '../../../hooks/useTranslation';
import { getPlayerTooltipText, getPlayerButtonClassName } from './utils';
import { teamColorStyle } from '../../../shared/styleHelpers';

interface ButtonProps {
  player: PlayerState;
  onClick?: () => void;
  isSelected?: boolean;
  disabled?: boolean;
  className?: string;
}

function Button({
  player,
  onClick,
  isSelected = false,
  disabled = false,
  className = '',
}: ButtonProps) {
  const { t } = useTranslation();
  const fouls = player.stats_values['fouls'] || 0;
  const [isAnimating, setIsAnimating] = React.useState(false);
  const previousFouls = React.useRef(fouls);

  // Player info states (derived from player data)
  const isDisqualified = player.state === 'disqualified';
  const isButtonDisabled = disabled || isDisqualified;

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
  return (
    <button
      className={getPlayerButtonClassName(
        player,
        isSelected,
        disabled,
        className,
      )}
      data-tooltip={getPlayerTooltipText(player, t)}
      onClick={onClick}
      disabled={isButtonDisabled}
    >
      <div className="content">
        {player.number !== null ? (
          <span className="number">{player.number}</span>
        ) : (
          <span className="name">{player.name}</span>
        )}
        {fouls > 0 && (
          <span className={`fouls ${isAnimating ? 'fouls-animate' : ''}`}>
            {fouls}
          </span>
        )}
        {player.is_captain && <span className="captain-indicator">C</span>}
      </div>
    </button>
  );
}

export default Button;
