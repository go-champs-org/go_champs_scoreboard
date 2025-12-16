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

/**
 * Type for translation function
 */
export type TranslationFunction = (key: string) => string;

/**
 * Generates tooltip text for a player button based on their state and fouls
 * @param player Player state to generate tooltip for
 * @param t Translation function
 * @returns Tooltip text or undefined if no tooltip needed
 */
export const getPlayerTooltipText = (
  player: PlayerState,
  t: TranslationFunction,
): string | undefined => {
  const isDisqualified = player.state === 'disqualified';
  const technicalFouls = player.stats_values['fouls_technical'] || 0;
  const unsportsmanlikeFouls =
    player.stats_values['fouls_unsportsmanlike'] || 0;
  const hasWarning =
    (technicalFouls >= 1 || unsportsmanlikeFouls >= 1) && !isDisqualified;

  if (isDisqualified) {
    return t('basketball.players.disqualified');
  }

  if (hasWarning) {
    if (technicalFouls >= 1 && unsportsmanlikeFouls >= 1) {
      return `${t(
        'basketball.players.warningTechnical',
      )} (${technicalFouls}) + ${t(
        'basketball.players.warningUnsportsmanlike',
      )} (${unsportsmanlikeFouls})`;
    } else if (technicalFouls >= 1) {
      return `${t('basketball.players.warningTechnical')} (${technicalFouls})`;
    } else if (unsportsmanlikeFouls >= 1) {
      return `${t(
        'basketball.players.warningUnsportsmanlike',
      )} (${unsportsmanlikeFouls})`;
    }
  }

  return undefined;
};

/**
 * User action state for player button styling
 */
export type UserActionState = 'normal' | 'selected' | 'disabled';

/**
 * Generates CSS class names for a player button based on state and props
 * @param player Player state
 * @param isSelected Whether the button is selected
 * @param disabled Whether the button is disabled
 * @param customClassName Additional custom CSS classes
 * @returns Complete CSS class string for the button
 */
export const getPlayerButtonClassName = (
  player: PlayerState,
  isSelected: boolean,
  disabled: boolean,
  customClassName: string = '',
): string => {
  // Player info states
  const isDisqualified = player.state === 'disqualified';
  const technicalFouls = player.stats_values['fouls_technical'] || 0;
  const unsportsmanlikeFouls =
    player.stats_values['fouls_unsportsmanlike'] || 0;
  const isWarning =
    (technicalFouls >= 1 || unsportsmanlikeFouls >= 1) && !isDisqualified;

  // User action state calculation
  const isButtonDisabled = disabled || isDisqualified;
  const userActionState: UserActionState = isButtonDisabled
    ? 'disabled'
    : isSelected
    ? 'selected'
    : 'normal';

  // Class assignment
  const baseClasses = 'player-button button';
  const userActionClasses: Record<UserActionState, string> = {
    normal: '',
    selected: 'is-dark',
    disabled: '',
  };

  const infoClasses: string[] = [];
  if (isDisqualified) infoClasses.push('is-disqualified');
  if (isWarning) infoClasses.push('has-foul-trouble');

  const tooltipClasses = isDisqualified || isWarning ? 'has-tooltip' : '';

  return [
    baseClasses,
    userActionClasses[userActionState],
    ...infoClasses,
    tooltipClasses,
    customClassName,
  ]
    .filter(Boolean)
    .join(' ');
};
