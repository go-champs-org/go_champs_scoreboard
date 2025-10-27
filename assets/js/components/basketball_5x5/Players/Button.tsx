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
  const fouls = 4;
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
      </div>
    </button>
  );
}

export default Button;
