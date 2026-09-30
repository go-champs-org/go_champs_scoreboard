import React from 'react';
import { render } from '@testing-library/react';
import AdditionalFoulButton from '../AdditionalFoulButton';
import { ViewSettingsProvider } from '../../../../shared/ViewSettingsContext';
import { RulesVersion } from '../../../../types';

describe('AdditionalFoulButton', () => {
  const renderCoachFoulButton = (rulesVersion: RulesVersion) => {
    const { container } = render(
      <ViewSettingsProvider selectedView="default" rulesVersion={rulesVersion}>
        <AdditionalFoulButton
          type="coach"
          disabled={false}
          label="MORE F."
          shortcut="B"
          onStatUpdate={jest.fn()}
        />
      </ViewSettingsProvider>,
    );

    return Array.from(
      container.querySelectorAll('.pop-up-container > div button'),
    ).map((button) => button.textContent);
  };

  it('keeps the current coach panel under fiba-2024', () => {
    expect(renderCoachFoulButton('fiba-2024')).toEqual([
      'C1',
      'CC',
      'B',
      'B1',
      'B2',
      'BC',
      'B',
      'B2',
      'D',
      'D1',
      'D2',
      'DC',
      'F',
    ]);
  });

  it('renders the FIBA 2026 coach panel under fiba-2026', () => {
    expect(renderCoachFoulButton('fiba-2026')).toEqual([
      'C',
      'C1',
      'CC',
      'B',
      'B1',
      'B2',
      'B3',
      'BC',
      'BD',
      'BD2',
      'BD×1',
      'BD×2',
      'BD2×1',
      'BD2×2',
      'D',
      'D1',
      'D2',
      'DC',
      'F',
    ]);
  });
});
