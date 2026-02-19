import React from 'react';

export function invokeButtonClickRef(
  ref: React.RefObject<HTMLButtonElement | null>,
) {
  if (ref.current?.disabled) {
    return;
  }

  ref.current?.classList.add('action');

  ref.current?.click();
  setTimeout(() => {
    ref.current?.classList.remove('action');
  }, 200);
}
