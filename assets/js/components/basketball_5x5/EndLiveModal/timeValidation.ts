const FORTY_FIVE_MINUTES_IN_MS = 45 * 60 * 1000;

export function shouldShowEarlyEndWarning(startedAt: string): boolean {
  const gameStartTime = new Date(startedAt);
  const now = new Date();
  return now.getTime() - gameStartTime.getTime() <= FORTY_FIVE_MINUTES_IN_MS;
}

export function getGameDurationInMinutes(startedAt: string): number {
  const gameStartTime = new Date(startedAt);
  const now = new Date();
  return Math.floor((now.getTime() - gameStartTime.getTime()) / (1000 * 60));
}
