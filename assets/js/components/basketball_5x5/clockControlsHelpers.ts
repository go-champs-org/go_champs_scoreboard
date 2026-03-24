import { GameClockState, LiveState, TeamState } from '../../../types';

export const isStartOfPeriod = (clock_state: GameClockState): boolean => {
  const referenceTime =
    clock_state.period > 4
      ? clock_state.initial_extra_period_time
      : clock_state.initial_period_time;
  return clock_state.time === referenceTime;
};

export const isTeamNotReady = (team: TeamState): boolean => {
  if ((team.stats_values['game_walkover'] || 0) > 0) return false;

  const playingCount = team.players.filter((p) => p.state === 'playing').length;
  const benchCount = team.players.filter(
    (p) => p.state === 'bench' || p.state === 'available',
  ).length;
  const totalAvailable = playingCount + benchCount;
  const requiredPlaying = Math.min(5, totalAvailable);
  return playingCount < requiredPlaying;
};

export const isClockButtonsDisabled = (
  live_state: LiveState,
  clock_state: GameClockState,
  home_team: TeamState,
  away_team: TeamState,
): boolean => {
  return (
    live_state?.state !== 'in_progress' ||
    (isStartOfPeriod(clock_state) &&
      (isTeamNotReady(home_team) || isTeamNotReady(away_team)))
  );
};
