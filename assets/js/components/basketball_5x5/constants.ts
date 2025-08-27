import { EVENT_KEYS } from '../../constants';
import { BasketballViews } from '../../types';

export const EVENT_KEYS_EDITABLE = [
  EVENT_KEYS.UPDATE_PLAYER_STAT,
  // EVENT_KEYS.UPDATE_COACH_STAT,
  // EVENT_KEYS.UPDATE_TEAM_STAT,
];

export interface PlayerStat {
  key: string;
  type: 'manual' | 'calculated' | 'automatic';
  view: BasketballViews[];
  abbreviationTranslationKey: string;
  labelTranslationKey: string;
}

export const PLAYER_STATS = [
  {
    key: 'assists',
    type: 'manual',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.assists',
    labelTranslationKey: 'basketball.stats.labels.assists',
  },
  {
    key: 'blocks',
    type: 'manual',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.blocks',
    labelTranslationKey: 'basketball.stats.labels.blocks',
  },
  {
    key: 'disqualifications',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.disqualifications',
    labelTranslationKey: 'basketball.stats.labels.disqualifications',
  },
  {
    key: 'ejections',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.ejections',
    labelTranslationKey: 'basketball.stats.labels.ejections',
  },
  {
    key: 'efficiency',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.efficiency',
    labelTranslationKey: 'basketball.stats.labels.efficiency',
  },
  {
    key: 'field_goal_percentage',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalPercentage',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalPercentage',
  },
  {
    key: 'field_goals_attempted',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalsAttempted',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsAttempted',
  },
  {
    key: 'field_goals_missed',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalsMissed',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsMissed',
  },
  {
    key: 'field_goals_made',
    type: 'manual',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.fieldGoalsMade',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsMade',
  },
  {
    key: 'fouls',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.fouls',
    labelTranslationKey: 'basketball.stats.labels.fouls',
  },
  {
    key: 'fouls_flagrant',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.flagrantFouls',
    labelTranslationKey: 'basketball.stats.labels.flagrantFouls',
  },
  {
    key: 'fouls_personal',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.personalFouls',
    labelTranslationKey: 'basketball.stats.labels.personalFouls',
  },
  {
    key: 'fouls_technical',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.technicalFouls',
    labelTranslationKey: 'basketball.stats.labels.technicalFouls',
  },
  {
    key: 'free_throw_percentage',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.onePointPercentage',
    labelTranslationKey: 'basketball.stats.labels.freeThrowPercentage',
  },
  {
    key: 'free_throws_attempted',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.freeThrowsAttempted',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsAttempted',
  },
  {
    key: 'free_throws_missed',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.freeThrowsMissed',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsMissed',
  },
  {
    key: 'free_throws_made',
    type: 'manual',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.onePoint',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsMade',
  },
  {
    key: 'minutes_played',
    type: 'automatic',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.minutesPlayed',
    labelTranslationKey: 'basketball.stats.labels.minutesPlayed',
  },
  {
    key: 'plus_minus',
    type: 'automatic',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.plusMinus',
    labelTranslationKey: 'basketball.stats.labels.plusMinus',
  },
  {
    key: 'points',
    type: 'calculated',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.points',
    labelTranslationKey: 'basketball.stats.labels.points',
  },
  {
    key: 'rebounds',
    type: 'calculated',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.rebounds',
    labelTranslationKey: 'basketball.stats.labels.rebounds',
  },
  {
    key: 'rebounds_defensive',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.defensiveRebounds',
    labelTranslationKey: 'basketball.stats.labels.defensiveRebounds',
  },
  {
    key: 'rebounds_offensive',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.offensiveRebounds',
    labelTranslationKey: 'basketball.stats.labels.offensiveRebounds',
  },
  {
    key: 'steals',
    type: 'manual',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.steals',
    labelTranslationKey: 'basketball.stats.labels.steals',
  },
  {
    key: 'three_point_field_goal_percentage',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointPercentage',
    labelTranslationKey:
      'basketball.stats.labels.threePointFieldGoalPercentage',
  },
  {
    key: 'three_point_field_goals_attempted',
    type: 'calculated',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointsAttempted',
    labelTranslationKey:
      'basketball.stats.labels.threePointFieldGoalsAttempted',
  },
  {
    key: 'three_point_field_goals_missed',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointsMissed',
    labelTranslationKey: 'basketball.stats.labels.threePointFieldGoalsMissed',
  },
  {
    key: 'three_point_field_goals_made',
    type: 'manual',
    view: ['basketball-basic', 'basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.threePoints',
    labelTranslationKey: 'basketball.stats.labels.threePointFieldGoalsMade',
  },
  {
    key: 'turnovers',
    type: 'manual',
    view: ['basketball-medium'],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.turnovers',
    labelTranslationKey: 'basketball.stats.labels.turnovers',
  },
] as const;

export const TEAM_STATS = {
  TIMEOUTS: 'timeouts',
  FOULS_TECHNICAL: 'fouls_technical',
  TOTAL_FOULS_TECHNICAL: 'total_fouls_technical',
} as const;

// Utility function to get manual player stats for a specific view
export const getManualPlayerStatsForView = (currentView: BasketballViews) => {
  return PLAYER_STATS.filter(
    (stat) => stat.type === 'manual' && stat.view.includes(currentView as any),
  );
};
