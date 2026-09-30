import React from 'react';
import { fireEvent, render } from '@testing-library/react';
import FoulButton from '../FoulButton';
import { ViewSettingsProvider } from '../../../../shared/ViewSettingsContext';
import { RulesVersion } from '../../../../types';

describe('FoulButton', () => {
  const renderTechnicalFoulButton = (rulesVersion: RulesVersion) => {
    const onStatUpdate = jest.fn();

    const { container } = render(
      <ViewSettingsProvider selectedView="default" rulesVersion={rulesVersion}>
        <FoulButton
          statId="fouls_technical"
          disabled={false}
          label="TECHNICAL F. (T)"
          shortcut="G"
          onStatUpdate={onStatUpdate}
        />
      </ViewSettingsProvider>,
    );

    const popUpButtons = Array.from(
      container.querySelectorAll('.pop-up-container > div button'),
    ) as HTMLButtonElement[];

    return { popUpButtons, onStatUpdate };
  };

  it('offers T1 and TC with and without circle under fiba-2026', () => {
    const { popUpButtons } = renderTechnicalFoulButton('fiba-2026');

    expect(
      popUpButtons.map((button) => ({
        text: button.textContent,
        isCircled: button.querySelector('.foul-letter.is-circled') !== null,
      })),
    ).toEqual([
      { text: 'T1', isCircled: false },
      { text: 'TC', isCircled: false },
      { text: 'T1', isCircled: true },
      { text: 'TC', isCircled: true },
    ]);
  });

  it('registers circled T1 as a category 1 technical foul under fiba-2026', () => {
    const { popUpButtons, onStatUpdate } =
      renderTechnicalFoulButton('fiba-2026');

    fireEvent.click(popUpButtons[2]);

    expect(onStatUpdate).toHaveBeenCalledWith('fouls_technical_category_1', {
      'free-throws-awarded': '1',
    });
  });

  it('registers T1 without circle as a technical foul under fiba-2026', () => {
    const { popUpButtons, onStatUpdate } =
      renderTechnicalFoulButton('fiba-2026');

    fireEvent.click(popUpButtons[0]);

    expect(onStatUpdate).toHaveBeenCalledWith('fouls_technical', {
      'free-throws-awarded': '1',
    });
  });

  it('keeps the fiba-2024 technical foul options', () => {
    const { popUpButtons } = renderTechnicalFoulButton('fiba-2024');

    expect(popUpButtons).toHaveLength(2);
    expect(
      popUpButtons.some((button) =>
        button.querySelector('.foul-letter.is-circled'),
      ),
    ).toBe(false);
  });
});
