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
    (coach.stats_values['fouls_game_disqualifying'] ?? 0) >= 1
  );
}

// Returns true when the player's state is not 'playing' — used to disable U fouls in the panel.
export function isPlayerUFoulsDisabled(player: PlayerState): boolean {
  return player.state !== 'playing';
}

// Returns true when the player already has a disqualifying foul — used to disable D fouls in the panel.
export function isPlayerDFoulsDisabled(player: PlayerState): boolean {
  return (player.stats_values['fouls_disqualifying'] ?? 0) >= 1;
}

// Returns true when the coach already has a disqualifying foul — used to disable all non-F fouls in the panel.
export function isCoachDFoulsDisabled(coach: CoachState): boolean {
  return (coach.stats_values['fouls_disqualifying'] ?? 0) >= 1;
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

// Disables all stat buttons when the selected player is not playing.
export function useButtonsDisabled(
  liveState: LiveState,
  selection: Selection | null,
): boolean {
  const baseDisabled = useBaseButtonsDisabled(liveState, selection);
  return React.useMemo(() => {
    if (baseDisabled) return true;
    const player = getSelectedPlayer(selection);
    return player !== null && player.state !== 'playing';
  }, [baseDisabled, selection]);
}

// Player: disabled only when player already has fouls_disqualifying_fighting or fouls_game_disqualifying.
// Coach:  disabled when coach already has fouls_disqualifying_fighting or fouls_technical_bench_disqualifying.
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
    if (player) return isPlayerAdditionalFoulDisabled(player);

    return true;
  }, [baseDisabled, selection]);
}

// Disables regular stat buttons for coach selections and non-playing players.
export function useStatButtonsDisabled(
  liveState: LiveState,
  selection: Selection | null,
): boolean {
  const baseDisabled = useBaseButtonsDisabled(liveState, selection);
  return React.useMemo(() => {
    if (baseDisabled) return true;
    if (selection?.kind === 'coach') return true;
    const player = getSelectedPlayer(selection);
    return player !== null && player.state !== 'playing';
  }, [baseDisabled, selection]);
}
