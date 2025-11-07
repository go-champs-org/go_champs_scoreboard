import React from 'react';
import { PlayerState } from '../../../types';

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
  const fouls = player.stats_values['fouls'] || 0;
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
  return (
    <button
      className={`player-button button ${
        isSelected ? 'is-dark' : ''
      } ${className}`}
      onClick={onClick}
      disabled={disabled}
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
      </div>
    </button>
  );
}

export default Button;
