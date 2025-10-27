import { PlayerState } from '../../../types';

/**
 * Filter function to find players who are currently playing
 * @param player Player state to check
 * @returns true if player is playing
 */
export const wherePlaying = (player: PlayerState): boolean => {
  return player.state === 'playing';
};

/**
 * Filter function to find players who are not playing (bench or injured, but not unavailable)
 * @param player Player state to check
 * @returns true if player is not playing but available
 */
export const whereNotPlaying = (player: PlayerState): boolean => {
  return player.state !== 'not_available' && player.state !== 'playing';
};

/**
 * Comparator function for sorting players by number (if available) then by name alphabetically
 * Players with numbers come before players without numbers
 * @param a First player to compare
 * @param b Second player to compare
 * @returns Sort comparison result
 */
export const byPlayer = (a: PlayerState, b: PlayerState): number => {
  // Parse numbers for comparison
  const aNumber = a.number ? parseInt(a.number, 10) : null;
  const bNumber = b.number ? parseInt(b.number, 10) : null;

  // If both players have valid numbers, sort by number
  if (
    aNumber !== null &&
    !isNaN(aNumber) &&
    bNumber !== null &&
    !isNaN(bNumber)
  ) {
    return aNumber - bNumber;
  }

  // If only one has a valid number, put numbered player first
  if (
    aNumber !== null &&
    !isNaN(aNumber) &&
    (bNumber === null || isNaN(bNumber))
  ) {
    return -1;
  }
  if (
    (aNumber === null || isNaN(aNumber)) &&
    bNumber !== null &&
    !isNaN(bNumber)
  ) {
    return 1;
  }

  // If neither has a valid number, sort by name
  return a.name.localeCompare(b.name);
};

/**
 * Sorts players by number (if available) then by name alphabetically
 * Players with numbers come before players without numbers
 * @param players Array of player states to sort
 * @returns New sorted array of players
 */
export const sortPlayers = (players: PlayerState[]): PlayerState[] => {
  return [...players].sort(byPlayer);
};
