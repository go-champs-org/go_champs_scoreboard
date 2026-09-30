import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react';
import Fiba2026PlayerFoulsPanel from '../Fiba2026PlayerFoulsPanel';

describe('Fiba2026PlayerFoulsPanel', () => {
  const renderPanel = (
    props: Partial<React.ComponentProps<typeof Fiba2026PlayerFoulsPanel>> = {},
  ) => {
    const onFoulWithoutFreeThrows = jest.fn();
    const onFoulWithFreeThrows = jest.fn();
    const panelRef = { close: jest.fn() };

    const { container } = render(
      <Fiba2026PlayerFoulsPanel
        panelRef={panelRef}
        onFoulWithoutFreeThrows={onFoulWithoutFreeThrows}
        onFoulWithFreeThrows={onFoulWithFreeThrows}
        firstButtonRef={React.createRef<HTMLButtonElement>()}
        {...props}
      />,
    );

    const buttonLabels = Array.from(container.querySelectorAll('button')).map(
      (button) => ({
        text: button.textContent,
        isCircled: button.querySelector('.foul-letter.is-circled') !== null,
      }),
    );

    return {
      container,
      buttonLabels,
      onFoulWithoutFreeThrows,
      onFoulWithFreeThrows,
      panelRef,
    };
  };

  it('does not render unsportsmanlike fouls', () => {
    const { buttonLabels } = renderPanel();

    expect(buttonLabels.some(({ text }) => text?.startsWith('U'))).toBe(false);
  });

  it('does not render technical fouls (they live in the technical foul popup)', () => {
    const { buttonLabels } = renderPanel();

    expect(buttonLabels.some(({ text }) => text?.startsWith('T'))).toBe(false);
  });

  it('renders DI without circle and FL with circle', () => {
    const { buttonLabels } = renderPanel();

    expect(buttonLabels.filter(({ text }) => text?.startsWith('DI'))).toEqual(
      ['DI', 'DI1', 'DI2', 'DI3', 'DIC'].map((text) => ({
        text,
        isCircled: false,
      })),
    );
    expect(buttonLabels.filter(({ text }) => text?.startsWith('FL'))).toEqual(
      ['FL', 'FL1', 'FL2', 'FL3', 'FLC'].map((text) => ({
        text,
        isCircled: true,
      })),
    );
  });

  it('registers DI and FL without free throws', () => {
    const { onFoulWithoutFreeThrows, panelRef } = renderPanel();

    fireEvent.click(screen.getByRole('button', { name: 'DI' }));
    fireEvent.click(screen.getByRole('button', { name: 'FL' }));

    expect(onFoulWithoutFreeThrows).toHaveBeenCalledWith(
      'fouls_disruptive',
      panelRef.close,
    );
    expect(onFoulWithoutFreeThrows).toHaveBeenCalledWith(
      'fouls_flagrant',
      panelRef.close,
    );
  });

  it('disables DI and FL but not F when the player is not on court', () => {
    const { container } = renderPanel({ disableOnCourtFouls: true });

    const buttons = Array.from(container.querySelectorAll('button'));
    const disabledFor = (prefix: string) =>
      buttons
        .filter((button) => button.textContent?.startsWith(prefix))
        .every((button) => button.disabled);

    expect(disabledFor('DI')).toBe(true);
    expect(disabledFor('FL')).toBe(true);
    expect(buttons.find((button) => button.textContent === 'F')?.disabled).toBe(
      false,
    );
  });
});
