import React from 'react';
import { fireEvent, render } from '@testing-library/react';
import Fiba2026CoachFoulsPanel from '../Fiba2026CoachFoulsPanel';

describe('Fiba2026CoachFoulsPanel', () => {
  const renderPanel = (
    props: Partial<React.ComponentProps<typeof Fiba2026CoachFoulsPanel>> = {},
  ) => {
    const onFoul = jest.fn();
    const panelRef = { close: jest.fn() };

    const { container } = render(
      <Fiba2026CoachFoulsPanel
        panelRef={panelRef}
        onFoul={onFoul}
        firstButtonRef={React.createRef<HTMLButtonElement>()}
        {...props}
      />,
    );

    const buttons = Array.from(
      container.querySelectorAll('button'),
    ) as HTMLButtonElement[];

    const buttonLabels = buttons.map((button) => ({
      text: button.textContent,
      isCircled: button.querySelector('.foul-letter.is-circled') !== null,
    }));

    const findButton = (text: string, isCircled: boolean) =>
      buttons[
        buttonLabels.findIndex(
          (label) => label.text === text && label.isCircled === isCircled,
        )
      ];

    return { buttonLabels, findButton, onFoul, panelRef };
  };

  it('renders C and B with circle', () => {
    const { buttonLabels } = renderPanel();

    expect(buttonLabels.filter(({ text }) => text?.startsWith('C'))).toEqual(
      ['C1', 'CC'].map((text) => ({ text, isCircled: true })),
    );
    expect(
      buttonLabels.filter(({ text }) => /^B[123C]?$/.test(text || '')),
    ).toEqual(
      ['B', 'B1', 'B2', 'BC'].map((text) => ({ text, isCircled: true })),
    );
  });

  it('renders BD with circle and BD without circle for 1 or 2 bench members', () => {
    const { buttonLabels } = renderPanel();

    expect(buttonLabels.filter(({ text }) => text?.startsWith('BD'))).toEqual([
      { text: 'BD', isCircled: true },
      { text: 'BD2', isCircled: true },
      { text: 'BD×1', isCircled: false },
      { text: 'BD×2', isCircled: false },
      { text: 'BD2×1', isCircled: false },
      { text: 'BD2×2', isCircled: false },
    ]);
  });

  it('records the circled BD with its free throws', () => {
    const { findButton, onFoul, panelRef } = renderPanel();

    fireEvent.click(findButton('BD2', true));

    expect(onFoul).toHaveBeenCalledWith(
      'fouls_technical_bench_disqualifying_circled',
      { 'free-throws-awarded': '2' },
      panelRef.close,
    );
  });

  it('records the BD without circle with the disqualified bench members', () => {
    const { findButton, onFoul, panelRef } = renderPanel();

    fireEvent.click(findButton('BD2×2', false));

    expect(onFoul).toHaveBeenCalledWith(
      'fouls_technical_bench_disqualifying',
      { 'free-throws-awarded': '2', 'disqualified-members': 2 },
      panelRef.close,
    );
  });

  it('records fouls without free throws without metadata', () => {
    const { findButton, onFoul, panelRef } = renderPanel();

    fireEvent.click(findButton('BD', true));

    expect(onFoul).toHaveBeenCalledWith(
      'fouls_technical_bench_disqualifying_circled',
      undefined,
      panelRef.close,
    );
  });

  it('disables all fouls but F when the coach has a disqualifying foul', () => {
    const { buttonLabels, findButton } = renderPanel({
      disableDisqualifying: true,
    });

    buttonLabels.forEach(({ text, isCircled }) => {
      expect(findButton(text || '', isCircled).disabled).toBe(text !== 'F');
    });
  });
});
