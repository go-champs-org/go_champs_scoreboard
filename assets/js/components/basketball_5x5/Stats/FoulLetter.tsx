import React from 'react';

interface FoulLetterProps {
  letter: string;
  /** Circled fouls count toward the game disqualification (FIBA 2026) */
  isCircled?: boolean;
  /** Free throws awarded (1, 2, 3 or C), drawn inside the circle */
  suffix?: string;
}

function FoulLetter({
  letter,
  isCircled = false,
  suffix = '',
}: FoulLetterProps) {
  return (
    <span className={isCircled ? 'foul-letter is-circled' : 'foul-letter'}>
      {letter}
      {suffix}
    </span>
  );
}

export default FoulLetter;
