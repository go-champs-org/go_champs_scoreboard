import { PLAYER_STATS, TEAM_STATS, COACH_STATS } from '../constants';

export function statIdToAbbreviationKey(statId: string) {
  const playerStat = PLAYER_STATS.find((stat) => stat.key === statId);
  return playerStat?.abbreviationTranslationKey || '';
}

export function teamStatIdToAbbreviationKey(statId: string) {
  const teamStat = TEAM_STATS.find((stat) => stat.key === statId);
  return teamStat?.abbreviationTranslationKey || '';
}

export function coachStatIdToAbbreviationKey(statId: string) {
  const coachStat = COACH_STATS.find((stat) => stat.key === statId);
  return coachStat?.abbreviationTranslationKey || '';
}
