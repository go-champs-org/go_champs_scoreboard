import { renderHook } from '@testing-library/react';
import {
  CoachState,
  LiveState,
  PlayerState,
  Selection,
} from '../../../../types';
import {
  getSelectedPlayer,
  getSelectedCoach,
  isPlayerAdditionalFoulDisabled,
  isCoachAdditionalFoulDisabled,
  useBaseButtonsDisabled,
  useButtonsDisabled,
  useAdditionalFoulButtonDisabled,
  useStatButtonsDisabled,
} from '../statsControlsHelpers';

// --- Fixtures ---

function makePlayer(
  overrides: Partial<PlayerState> = {},
  statsOverrides: { [key: string]: number } = {},
): PlayerState {
  return {
    id: 'player-1',
    name: 'John Doe',
    number: '10',
    license_number: '',
    state: 'playing',
    is_captain: false,
    stats_values: statsOverrides,
    ...overrides,
  };
}

function makeCoach(
  overrides: Partial<CoachState> = {},
  statsOverrides: { [key: string]: number } = {},
): CoachState {
  return {
    id: 'coach-1',
    name: 'Coach Smith',
    type: 'head_coach',
    state: 'available',
    stats_values: statsOverrides,
    ...overrides,
  };
}

function makeLiveState(state: LiveState['state'] = 'in_progress'): LiveState {
  return { state, started_at: '', ended_at: '' };
}

function makePlayerSelection(
  player: PlayerState,
  teamType: 'home' | 'away' = 'home',
): Selection {
  return { kind: 'player', teamType, player };
}

function makeCoachSelection(
  coach: CoachState,
  teamType: 'home' | 'away' = 'home',
): Selection {
  return { kind: 'coach', teamType, coach };
}

// --- getSelectedPlayer ---

describe('getSelectedPlayer', () => {
  it('returns null when selection is null', () => {
    expect(getSelectedPlayer(null)).toBeNull();
  });

  it('returns null for a coach selection', () => {
    const selection = makeCoachSelection(makeCoach());
    expect(getSelectedPlayer(selection)).toBeNull();
  });

  it('returns the player for a player selection', () => {
    const player = makePlayer();
    const selection = makePlayerSelection(player);
    expect(getSelectedPlayer(selection)).toBe(player);
  });
});

// --- getSelectedCoach ---

describe('getSelectedCoach', () => {
  it('returns null when selection is null', () => {
    expect(getSelectedCoach(null)).toBeNull();
  });

  it('returns null for a player selection', () => {
    const selection = makePlayerSelection(makePlayer());
    expect(getSelectedCoach(selection)).toBeNull();
  });

  it('returns the coach for a coach selection', () => {
    const coach = makeCoach();
    const selection = makeCoachSelection(coach);
    expect(getSelectedCoach(selection)).toBe(coach);
  });
});

// --- isPlayerAdditionalFoulDisabled ---

describe('isPlayerAdditionalFoulDisabled', () => {
  it('returns false when player has no disqualifying fouls', () => {
    expect(isPlayerAdditionalFoulDisabled(makePlayer())).toBe(false);
  });

  it('returns false when disqualifying foul stats are 0', () => {
    const player = makePlayer(
      {},
      {
        fouls_disqualifying_fighting: 0,
        fouls_game_disqualifying: 0,
      },
    );
    expect(isPlayerAdditionalFoulDisabled(player)).toBe(false);
  });

  it('returns true when player has fouls_disqualifying_fighting >= 1', () => {
    const player = makePlayer({}, { fouls_disqualifying_fighting: 1 });
    expect(isPlayerAdditionalFoulDisabled(player)).toBe(true);
  });

  it('returns true when player has fouls_game_disqualifying >= 1', () => {
    const player = makePlayer({}, { fouls_game_disqualifying: 1 });
    expect(isPlayerAdditionalFoulDisabled(player)).toBe(true);
  });

  it('returns true when player has both disqualifying foul types', () => {
    const player = makePlayer(
      {},
      {
        fouls_disqualifying_fighting: 1,
        fouls_game_disqualifying: 1,
      },
    );
    expect(isPlayerAdditionalFoulDisabled(player)).toBe(true);
  });
});

// --- isCoachAdditionalFoulDisabled ---

describe('isCoachAdditionalFoulDisabled', () => {
  it('returns false when coach has no disqualifying fouls', () => {
    expect(isCoachAdditionalFoulDisabled(makeCoach())).toBe(false);
  });

  it('returns false when disqualifying foul stats are 0', () => {
    const coach = makeCoach(
      {},
      {
        fouls_disqualifying_fighting: 0,
        fouls_technical_bench_disqualifying: 0,
      },
    );
    expect(isCoachAdditionalFoulDisabled(coach)).toBe(false);
  });

  it('returns true when coach has fouls_disqualifying_fighting >= 1', () => {
    const coach = makeCoach({}, { fouls_disqualifying_fighting: 1 });
    expect(isCoachAdditionalFoulDisabled(coach)).toBe(true);
  });

  it('returns true when coach has fouls_technical_bench_disqualifying >= 1', () => {
    const coach = makeCoach({}, { fouls_technical_bench_disqualifying: 1 });
    expect(isCoachAdditionalFoulDisabled(coach)).toBe(true);
  });

  it('returns true when coach has both disqualifying foul types', () => {
    const coach = makeCoach(
      {},
      {
        fouls_disqualifying_fighting: 1,
        fouls_technical_bench_disqualifying: 1,
      },
    );
    expect(isCoachAdditionalFoulDisabled(coach)).toBe(true);
  });
});

// --- useBaseButtonsDisabled ---

describe('useBaseButtonsDisabled', () => {
  it('returns true when game is not in progress', () => {
    const { result } = renderHook(() =>
      useBaseButtonsDisabled(
        makeLiveState('not_started'),
        makePlayerSelection(makePlayer()),
      ),
    );
    expect(result.current).toBe(true);
  });

  it('returns true when game has ended', () => {
    const { result } = renderHook(() =>
      useBaseButtonsDisabled(
        makeLiveState('ended'),
        makePlayerSelection(makePlayer()),
      ),
    );
    expect(result.current).toBe(true);
  });

  it('returns true when selection is null', () => {
    const { result } = renderHook(() =>
      useBaseButtonsDisabled(makeLiveState('in_progress'), null),
    );
    expect(result.current).toBe(true);
  });

  it('returns false when game is in progress and selection is set', () => {
    const { result } = renderHook(() =>
      useBaseButtonsDisabled(
        makeLiveState('in_progress'),
        makePlayerSelection(makePlayer()),
      ),
    );
    expect(result.current).toBe(false);
  });
});

// --- useButtonsDisabled ---

describe('useButtonsDisabled', () => {
  it('returns true when base is disabled', () => {
    const { result } = renderHook(() =>
      useButtonsDisabled(
        makeLiveState('not_started'),
        makePlayerSelection(makePlayer()),
      ),
    );
    expect(result.current).toBe(true);
  });

  it('returns false for a playing player during a live game', () => {
    const { result } = renderHook(() =>
      useButtonsDisabled(
        makeLiveState('in_progress'),
        makePlayerSelection(makePlayer({ state: 'playing' })),
      ),
    );
    expect(result.current).toBe(false);
  });

  it('returns true for a disqualified player even when game is in progress', () => {
    const { result } = renderHook(() =>
      useButtonsDisabled(
        makeLiveState('in_progress'),
        makePlayerSelection(makePlayer({ state: 'disqualified' })),
      ),
    );
    expect(result.current).toBe(true);
  });
});

// --- useStatButtonsDisabled ---

describe('useStatButtonsDisabled', () => {
  it('returns true when base is disabled', () => {
    const { result } = renderHook(() =>
      useStatButtonsDisabled(
        makeLiveState('not_started'),
        makePlayerSelection(makePlayer()),
      ),
    );
    expect(result.current).toBe(true);
  });

  it('returns false for a playing player during a live game', () => {
    const { result } = renderHook(() =>
      useStatButtonsDisabled(
        makeLiveState('in_progress'),
        makePlayerSelection(makePlayer({ state: 'playing' })),
      ),
    );
    expect(result.current).toBe(false);
  });

  it('returns true for a disqualified player', () => {
    const { result } = renderHook(() =>
      useStatButtonsDisabled(
        makeLiveState('in_progress'),
        makePlayerSelection(makePlayer({ state: 'disqualified' })),
      ),
    );
    expect(result.current).toBe(true);
  });

  it('returns true for a coach selection', () => {
    const { result } = renderHook(() =>
      useStatButtonsDisabled(
        makeLiveState('in_progress'),
        makeCoachSelection(makeCoach()),
      ),
    );
    expect(result.current).toBe(true);
  });
});

// --- useAdditionalFoulButtonDisabled ---

describe('useAdditionalFoulButtonDisabled', () => {
  describe('base guard', () => {
    it('returns true when game is not in progress', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('not_started'),
          makePlayerSelection(makePlayer({ state: 'disqualified' })),
        ),
      );
      expect(result.current).toBe(true);
    });

    it('returns true when selection is null', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(makeLiveState('in_progress'), null),
      );
      expect(result.current).toBe(true);
    });
  });

  describe('player selection', () => {
    it('returns false for a playing (non-disqualified) player', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makePlayerSelection(makePlayer({ state: 'playing' })),
        ),
      );
      expect(result.current).toBe(false);
    });

    it('returns false for a disqualified player with no blocking fouls', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makePlayerSelection(makePlayer({ state: 'disqualified' })),
        ),
      );
      expect(result.current).toBe(false);
    });

    it('returns true for a disqualified player who already has fouls_disqualifying_fighting', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makePlayerSelection(
            makePlayer(
              { state: 'disqualified' },
              { fouls_disqualifying_fighting: 1 },
            ),
          ),
        ),
      );
      expect(result.current).toBe(true);
    });

    it('returns true for a disqualified player who already has fouls_game_disqualifying', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makePlayerSelection(
            makePlayer(
              { state: 'disqualified' },
              { fouls_game_disqualifying: 1 },
            ),
          ),
        ),
      );
      expect(result.current).toBe(true);
    });
  });

  describe('coach selection', () => {
    it('returns false for a coach with no blocking fouls', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makeCoachSelection(makeCoach()),
        ),
      );
      expect(result.current).toBe(false);
    });

    it('returns true when coach has fouls_disqualifying_fighting', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makeCoachSelection(
            makeCoach({}, { fouls_disqualifying_fighting: 1 }),
          ),
        ),
      );
      expect(result.current).toBe(true);
    });

    it('returns true when coach has fouls_technical_bench_disqualifying', () => {
      const { result } = renderHook(() =>
        useAdditionalFoulButtonDisabled(
          makeLiveState('in_progress'),
          makeCoachSelection(
            makeCoach({}, { fouls_technical_bench_disqualifying: 1 }),
          ),
        ),
      );
      expect(result.current).toBe(true);
    });
  });
});
