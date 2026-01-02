import {
  shouldShowEarlyEndWarning,
  getGameDurationInMinutes,
} from '../timeValidation';

describe('timeValidation', () => {
  beforeEach(() => {
    // Mock current time to ensure consistent tests
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2026-01-01T12:00:00Z'));
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe('shouldShowEarlyEndWarning', () => {
    it('returns true for games started less than 45 minutes ago', () => {
      const thirtyMinutesAgo = new Date(
        Date.now() - 30 * 60 * 1000,
      ).toISOString();
      expect(shouldShowEarlyEndWarning(thirtyMinutesAgo)).toBe(true);
    });

    it('returns false for games started more than 45 minutes ago', () => {
      const sixtyMinutesAgo = new Date(
        Date.now() - 60 * 60 * 1000,
      ).toISOString();
      expect(shouldShowEarlyEndWarning(sixtyMinutesAgo)).toBe(false);
    });

    it('returns true for games started exactly 45 minutes ago', () => {
      const fortyFiveMinutesAgo = new Date(
        Date.now() - 45 * 60 * 1000,
      ).toISOString();
      expect(shouldShowEarlyEndWarning(fortyFiveMinutesAgo)).toBe(true);
    });

    it('returns false for games started exactly 46 minutes ago', () => {
      const fortySixMinutesAgo = new Date(
        Date.now() - 46 * 60 * 1000,
      ).toISOString();
      expect(shouldShowEarlyEndWarning(fortySixMinutesAgo)).toBe(false);
    });
  });

  describe('getGameDurationInMinutes', () => {
    it('calculates correct duration for games started 30 minutes ago', () => {
      const thirtyMinutesAgo = new Date(
        Date.now() - 30 * 60 * 1000,
      ).toISOString();
      expect(getGameDurationInMinutes(thirtyMinutesAgo)).toBe(30);
    });

    it('calculates correct duration for games started 2 hours ago', () => {
      const twoHoursAgo = new Date(
        Date.now() - 2 * 60 * 60 * 1000,
      ).toISOString();
      expect(getGameDurationInMinutes(twoHoursAgo)).toBe(120);
    });

    it('returns 0 for games started just now', () => {
      const now = new Date().toISOString();
      expect(getGameDurationInMinutes(now)).toBe(0);
    });
  });
});
