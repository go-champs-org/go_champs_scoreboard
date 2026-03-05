import React from 'react';
import { CoachState, LiveState, PlayerState, Selection } from '../../../types';

// --- Selection helpers ---

export function getSelectedPlayer(
  selection: Selection | null,
): PlayerState | null {
  if (!selection || selection.kind !== 'player') return null;
  return selection.player;
}

export function getSelectedCoach(
  selection: Selection | null,
): CoachState | null {
  if (!selection || selection.kind !== 'coach') return null;
  return selection.coach;
}

// --- Pure per-entity disabled logic ---

export function isPlayerAdditionalFoulDisabled(player: PlayerState): boolean {
  return (
    (player.stats_values['fouls_disqualifying_fighting'] ?? 0) >= 1 ||
    (player.stats_values['fouls_game_disqualifying'] ?? 0) >= 1
  );
}

export function isCoachAdditionalFoulDisabled(coach: CoachState): boolean {
  return (
    (coach.stats_values['fouls_disqualifying_fighting'] ?? 0) >= 1 ||
    (coach.stats_values['fouls_technical_bench_disqualifying'] ?? 0) >= 1
  );
}

// --- Hooks ---

export function useBaseButtonsDisabled(
  liveState: LiveState,
  selection: Selection | null,
): boolean {
  return React.useMemo(
    () => liveState.state !== 'in_progress' || selection === null,
    [liveState.state, selection],
  );
}

// Disables all stat buttons when the selected player is disqualified (not playing).
export function useButtonsDisabled(
  liveState: LiveState,
  selection: Selection | null,
): boolean {
  const baseDisabled = useBaseButtonsDisabled(liveState, selection);
  return React.useMemo(
    () =>
      baseDisabled || getSelectedPlayer(selection)?.state === 'disqualified',
    [baseDisabled, selection],
  );
}

// Player: enabled only when player is disqualified and hasn't yet received a
//         fouls_disqualifying_fighting or fouls_game_disqualifying foul.
// Coach:  enabled unless coach already has fouls_disqualifying_fighting or
//         fouls_technical_bench_disqualifying.
export function useAdditionalFoulButtonDisabled(
  liveState: LiveState,
  selection: Selection | null,
): boolean {
  const baseDisabled = useBaseButtonsDisabled(liveState, selection);
  return React.useMemo(() => {
    if (baseDisabled) return true;

    const coach = getSelectedCoach(selection);
    if (coach) return isCoachAdditionalFoulDisabled(coach);

    const player = getSelectedPlayer(selection);
    if (player) {
      if (player.state === 'playing') return false;
      return (
        player.state !== 'disqualified' ||
        isPlayerAdditionalFoulDisabled(player)
      );
    }

    return true;
  }, [baseDisabled, selection]);
}

// Disables regular stat buttons for coach selections and disqualified players.
export function useStatButtonsDisabled(
  liveState: LiveState,
  selection: Selection | null,
): boolean {
  const baseDisabled = useBaseButtonsDisabled(liveState, selection);
  return React.useMemo(
    () =>
      baseDisabled ||
      selection?.kind === 'coach' ||
      getSelectedPlayer(selection)?.state === 'disqualified',
    [baseDisabled, selection],
  );
}
