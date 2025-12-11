import { PLAYER_STATS, TEAM_STATS } from '../constants';

export function statIdToAbbreviationKey(statId: string) {
  const playerStat = PLAYER_STATS.find((stat) => stat.key === statId);
  return playerStat?.abbreviationTranslationKey || '';
}

export function teamStatIdToAbbreviationKey(statId: string) {
  const teamStat = TEAM_STATS.find((stat) => stat.key === statId);
  return teamStat?.abbreviationTranslationKey || '';
}
