import {
  isStartOfPeriod,
  isTeamNotReady,
  isClockButtonsDisabled,
} from '../clockControlsHelpers';
import { GameClockState, LiveState, TeamState } from '../../../types';

const makeClockState = (
  overrides: Partial<GameClockState> = {},
): GameClockState => ({
  initial_period_time: 600,
  initial_extra_period_time: 300,
  time: 600,
  period: 1,
  state: 'paused',
  started_at: '',
  finished_at: '',
  ...overrides,
});

const makeTeam = (
  players: { state: TeamState['players'][number]['state'] }[] = [],
  statsValues: { [key: string]: number } = {},
): TeamState => ({
  id: 'team-1',
  name: 'Team',
  tri_code: 'TM',
  logo_url: '',
  primary_color: '',
  coaches: [],
  period_stats: {},
  total_player_stats: {},
  stats_values: statsValues,
  players: players.map((p, i) => ({
    id: `player-${i}`,
    name: `Player ${i}`,
    number: `${i}`,
    license_number: '',
    is_captain: false,
    stats_values: {},
    state: p.state,
  })),
});

const inProgressLiveState: LiveState = {
  state: 'in_progress',
  started_at: '',
  ended_at: '',
};

const notStartedLiveState: LiveState = {
  state: 'not_started',
  started_at: '',
  ended_at: '',
};

// ---------------------------------------------------------------------------
// isStartOfPeriod
// ---------------------------------------------------------------------------
describe('isStartOfPeriod', () => {
  it('returns true when time equals initial_period_time for a regular period', () => {
    expect(isStartOfPeriod(makeClockState({ period: 1, time: 600 }))).toBe(
      true,
    );
  });

  it('returns true for period 4 when time equals initial_period_time', () => {
    expect(isStartOfPeriod(makeClockState({ period: 4, time: 600 }))).toBe(
      true,
    );
  });

  it('returns false when time differs from initial_period_time for a regular period', () => {
    expect(isStartOfPeriod(makeClockState({ period: 2, time: 400 }))).toBe(
      false,
    );
  });

  it('returns true for an extra period when time equals initial_extra_period_time', () => {
    expect(isStartOfPeriod(makeClockState({ period: 5, time: 300 }))).toBe(
      true,
    );
  });

  it('returns false for an extra period when time differs from initial_extra_period_time', () => {
    expect(isStartOfPeriod(makeClockState({ period: 5, time: 200 }))).toBe(
      false,
    );
  });

  it('uses initial_extra_period_time and not initial_period_time for periods > 4', () => {
    // time matches initial_period_time but not initial_extra_period_time
    expect(
      isStartOfPeriod(
        makeClockState({
          period: 6,
          time: 600,
          initial_period_time: 600,
          initial_extra_period_time: 300,
        }),
      ),
    ).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// isTeamNotReady
// ---------------------------------------------------------------------------
describe('isTeamNotReady', () => {
  describe('game_walkover', () => {
    it('returns false (team is ready) when game_walkover > 0, even with no players', () => {
      const team = makeTeam([], { game_walkover: 1 });
      expect(isTeamNotReady(team)).toBe(false);
    });

    it('performs normal check when game_walkover is 0', () => {
      const team = makeTeam([], { game_walkover: 0 });
      expect(isTeamNotReady(team)).toBe(false); // 0 available, 0 required → ready
    });
  });

  describe('team with >= 5 available players', () => {
    it('returns true when fewer than 5 players are playing', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'available' },
        { state: 'available' },
        { state: 'bench' },
      ]);
      expect(isTeamNotReady(team)).toBe(true);
    });

    it('returns false when exactly 5 players are playing', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
      ]);
      expect(isTeamNotReady(team)).toBe(false);
    });

    it('returns true when 5 bench players and 0 playing', () => {
      const team = makeTeam([
        { state: 'bench' },
        { state: 'bench' },
        { state: 'bench' },
        { state: 'bench' },
        { state: 'bench' },
      ]);
      expect(isTeamNotReady(team)).toBe(true);
    });

    it('returns true when 6 available players but only 4 playing', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'available' },
        { state: 'available' },
      ]);
      expect(isTeamNotReady(team)).toBe(true);
    });

    it('returns false when 6 available players and 5 are playing', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'bench' },
      ]);
      expect(isTeamNotReady(team)).toBe(false);
    });
  });

  describe('team with fewer than 5 available players', () => {
    it('returns false when all available players are playing (3 of 3)', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
      ]);
      expect(isTeamNotReady(team)).toBe(false);
    });

    it('returns true when not all available players are playing (1 of 3)', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'available' },
        { state: 'bench' },
      ]);
      expect(isTeamNotReady(team)).toBe(true);
    });

    it('returns false when there are 0 available players', () => {
      const team = makeTeam([]);
      expect(isTeamNotReady(team)).toBe(false);
    });
  });

  describe('excluded player states', () => {
    it('does not count disqualified players toward the required total', () => {
      // 4 playing + 1 disqualified → total active = 4, required = 4 → ready
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'disqualified' },
      ]);
      expect(isTeamNotReady(team)).toBe(false);
    });

    it('does not count injured players toward the required total', () => {
      // 4 playing + 1 injured → total active = 4, required = 4 → ready
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'injured' },
      ]);
      expect(isTeamNotReady(team)).toBe(false);
    });

    it('does not count not_available players toward the required total', () => {
      const team = makeTeam([
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'playing' },
        { state: 'not_available' },
      ]);
      expect(isTeamNotReady(team)).toBe(false);
    });
  });
});

// ---------------------------------------------------------------------------
// isClockButtonsDisabled
// ---------------------------------------------------------------------------
describe('isClockButtonsDisabled', () => {
  const readyTeam = makeTeam([
    { state: 'playing' },
    { state: 'playing' },
    { state: 'playing' },
    { state: 'playing' },
    { state: 'playing' },
  ]);

  const notReadyTeam = makeTeam([
    { state: 'available' },
    { state: 'available' },
    { state: 'available' },
    { state: 'available' },
    { state: 'available' },
  ]);

  it('returns true when live state is not in_progress', () => {
    const clock = makeClockState({ time: 600 });
    expect(
      isClockButtonsDisabled(notStartedLiveState, clock, readyTeam, readyTeam),
    ).toBe(true);
  });

  it('returns false when in_progress, at period start, and both teams are ready', () => {
    const clock = makeClockState({ time: 600 });
    expect(
      isClockButtonsDisabled(inProgressLiveState, clock, readyTeam, readyTeam),
    ).toBe(false);
  });

  it('returns true when in_progress, at period start, and home team is not ready', () => {
    const clock = makeClockState({ time: 600 });
    expect(
      isClockButtonsDisabled(
        inProgressLiveState,
        clock,
        notReadyTeam,
        readyTeam,
      ),
    ).toBe(true);
  });

  it('returns true when in_progress, at period start, and away team is not ready', () => {
    const clock = makeClockState({ time: 600 });
    expect(
      isClockButtonsDisabled(
        inProgressLiveState,
        clock,
        readyTeam,
        notReadyTeam,
      ),
    ).toBe(true);
  });

  it('returns false when in_progress but NOT at period start, even if teams are not ready', () => {
    const clock = makeClockState({ time: 400 }); // time !== initial_period_time (600)
    expect(
      isClockButtonsDisabled(
        inProgressLiveState,
        clock,
        notReadyTeam,
        notReadyTeam,
      ),
    ).toBe(false);
  });

  it('returns false when in_progress, at extra period start, and both teams have walkover', () => {
    const clock = makeClockState({ period: 5, time: 300 });
    const walkoverTeam = makeTeam([], { game_walkover: 1 });
    expect(
      isClockButtonsDisabled(
        inProgressLiveState,
        clock,
        walkoverTeam,
        walkoverTeam,
      ),
    ).toBe(false);
  });
});
