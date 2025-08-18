import { PLAYER_STATS } from '../constants';

export function statIdToAbbreviationKey(statId: string) {
  const playerStat = PLAYER_STATS.find((stat) => stat.key === statId);
  return playerStat?.abbreviationTranslationKey || '';
}
