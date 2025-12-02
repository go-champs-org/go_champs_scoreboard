import { BLUE, colorForPeriod, RED } from '../styles';

describe('FibaScoresheet styles', () => {
  it('returns red when period is 1', () => {
    expect(colorForPeriod(1)).toBe(RED);
  });

  it('returns blue when period is 2', () => {
    expect(colorForPeriod(2)).toBe(BLUE);
  });

  it('returns red when period is 3', () => {
    expect(colorForPeriod(3)).toBe(RED);
  });

  it('returns blue when period is 4', () => {
    expect(colorForPeriod(4)).toBe(BLUE);
  });

  it('returns blue when period is 5', () => {
    expect(colorForPeriod(5)).toBe(BLUE);
  });
});
