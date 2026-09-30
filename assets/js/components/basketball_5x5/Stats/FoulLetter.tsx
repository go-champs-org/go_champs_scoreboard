import React from 'react';

interface FoulLetterProps {
  letter: string;
  /** Circled fouls count toward the game disqualification (FIBA 2026) */
  isCircled?: boolean;
  suffix?: string;
}

function FoulLetter({
  letter,
  isCircled = false,
  suffix = '',
}: FoulLetterProps) {
  return (
    <>
      <span className={isCircled ? 'foul-letter is-circled' : 'foul-letter'}>
        {letter}
      </span>
      {suffix}
    </>
  );
}

export default FoulLetter;
