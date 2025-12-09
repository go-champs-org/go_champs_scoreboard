import { EVENT_KEYS } from '../../constants';
import { BasketballViews } from '../../types';

export const LIVE_MODE_EVENT_KEYS = [
  EVENT_KEYS.START_GAME_LIVE_MODE,
  EVENT_KEYS.END_GAME_LIVE_MODE,
  EVENT_KEYS.RESET_GAME_LIVE_MODE,
];

export const EVENT_KEYS_EDITABLE = [
  EVENT_KEYS.UPDATE_PLAYER_STAT,
  EVENT_KEYS.UPDATE_PLAYERS_STATE,
  EVENT_KEYS.UPDATE_COACH_STAT,
  EVENT_KEYS.UPDATE_TEAM_STAT,
];

// Stat keys constant for semantic ordering and reference
export const STAT_KEYS = {
  // Scoring stats
  FIELD_GOALS_MADE: 'field_goals_made',
  FIELD_GOALS_ATTEMPTED: 'field_goals_attempted',
  FIELD_GOALS_MISSED: 'field_goals_missed',
  THREE_POINT_FIELD_GOALS_MADE: 'three_point_field_goals_made',
  THREE_POINT_FIELD_GOALS_ATTEMPTED: 'three_point_field_goals_attempted',
  THREE_POINT_FIELD_GOALS_MISSED: 'three_point_field_goals_missed',
  FREE_THROWS_MADE: 'free_throws_made',
  FREE_THROWS_ATTEMPTED: 'free_throws_attempted',
  FREE_THROWS_MISSED: 'free_throws_missed',

  // Rebounding stats
  REBOUNDS_OFFENSIVE: 'rebounds_offensive',
  REBOUNDS_DEFENSIVE: 'rebounds_defensive',
  REBOUNDS: 'rebounds',

  // Playmaking stats
  ASSISTS: 'assists',
  STEALS: 'steals',
  BLOCKS: 'blocks',
  TURNOVERS: 'turnovers',

  // Fouls
  FOULS_PERSONAL: 'fouls_personal',
  FOULS_TECHNICAL: 'fouls_technical',
  FOULS_UNSPORTSMANLIKE: 'fouls_unsportsmanlike',
  FOULS_DISQUALIFYING: 'fouls_disqualifying',
  FOULS_DISQUALIFYING_FIGHTING: 'fouls_disqualifying_fighting',
  FOULS_GAME_DISQUALIFYING: 'fouls_game_disqualifying',
  FOULS: 'fouls',

  // Calculated stats
  POINTS: 'points',
  FIELD_GOAL_PERCENTAGE: 'field_goal_percentage',
  THREE_POINT_FIELD_GOAL_PERCENTAGE: 'three_point_field_goal_percentage',
  FREE_THROW_PERCENTAGE: 'free_throw_percentage',
  EFFICIENCY: 'efficiency',

  // Time and other stats
  MINUTES_PLAYED: 'minutes_played',
  PLUS_MINUS: 'plus_minus',
  DISQUALIFICATIONS: 'disqualifications',
  EJECTIONS: 'ejections',
} as const;

// Stat types constant
export const STAT_TYPES = {
  MANUAL: 'manual',
  CALCULATED: 'calculated',
  AUTOMATIC: 'automatic',
} as const;

// Basketball views constant
export const BASKETBALL_VIEWS: Record<string, BasketballViews> = {
  BASIC: 'basketball-basic',
  MEDIUM: 'basketball-medium',
} as const;

export interface PlayerStat {
  key: string;
  type: (typeof STAT_TYPES)[keyof typeof STAT_TYPES];
  view: BasketballViews[];
  abbreviationTranslationKey: string;
  labelTranslationKey: string;
}

export const PLAYER_STATS = [
  {
    key: STAT_KEYS.ASSISTS,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.assists',
    labelTranslationKey: 'basketball.stats.labels.assists',
  },
  {
    key: STAT_KEYS.BLOCKS,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.blocks',
    labelTranslationKey: 'basketball.stats.labels.blocks',
  },
  {
    key: STAT_KEYS.EFFICIENCY,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.efficiency',
    labelTranslationKey: 'basketball.stats.labels.efficiency',
  },
  {
    key: STAT_KEYS.FIELD_GOAL_PERCENTAGE,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalPercentage',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalPercentage',
  },
  {
    key: STAT_KEYS.FIELD_GOALS_ATTEMPTED,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalsAttempted',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsAttempted',
  },
  {
    key: STAT_KEYS.FIELD_GOALS_MISSED,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalsMissed',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsMissed',
  },
  {
    key: STAT_KEYS.FIELD_GOALS_MADE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.fieldGoalsMade',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsMade',
  },
  {
    key: STAT_KEYS.FOULS,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.fouls',
    labelTranslationKey: 'basketball.stats.labels.fouls',
  },
  {
    key: STAT_KEYS.FOULS_UNSPORTSMANLIKE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.unsportsmanlikeFouls',
    labelTranslationKey: 'basketball.stats.labels.unsportsmanlikeFouls',
  },
  {
    key: STAT_KEYS.FOULS_PERSONAL,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.personalFouls',
    labelTranslationKey: 'basketball.stats.labels.personalFouls',
  },
  {
    key: STAT_KEYS.FOULS_TECHNICAL,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.technicalFouls',
    labelTranslationKey: 'basketball.stats.labels.technicalFouls',
  },
  {
    key: STAT_KEYS.FOULS_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.disqualifyingFouls',
    labelTranslationKey: 'basketball.stats.labels.disqualifyingFouls',
  },
  {
    key: STAT_KEYS.FOULS_DISQUALIFYING_FIGHTING,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.disqualifyingFightingFouls',
    labelTranslationKey: 'basketball.stats.labels.disqualifyingFightingFouls',
  },
  {
    key: STAT_KEYS.FOULS_GAME_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.gameDisqualifyingFouls',
    labelTranslationKey: 'basketball.stats.labels.gameDisqualifyingFouls',
  },
  {
    key: STAT_KEYS.FREE_THROW_PERCENTAGE,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.onePointPercentage',
    labelTranslationKey: 'basketball.stats.labels.freeThrowPercentage',
  },
  {
    key: STAT_KEYS.FREE_THROWS_ATTEMPTED,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.freeThrowsAttempted',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsAttempted',
  },
  {
    key: STAT_KEYS.FREE_THROWS_MISSED,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.freeThrowsMissed',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsMissed',
  },
  {
    key: STAT_KEYS.FREE_THROWS_MADE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.onePoint',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsMade',
  },
  {
    key: STAT_KEYS.MINUTES_PLAYED,
    type: STAT_TYPES.AUTOMATIC,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.minutesPlayed',
    labelTranslationKey: 'basketball.stats.labels.minutesPlayed',
  },
  {
    key: STAT_KEYS.PLUS_MINUS,
    type: STAT_TYPES.AUTOMATIC,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.plusMinus',
    labelTranslationKey: 'basketball.stats.labels.plusMinus',
  },
  {
    key: STAT_KEYS.POINTS,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.points',
    labelTranslationKey: 'basketball.stats.labels.points',
  },
  {
    key: STAT_KEYS.REBOUNDS,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.rebounds',
    labelTranslationKey: 'basketball.stats.labels.rebounds',
  },
  {
    key: STAT_KEYS.REBOUNDS_DEFENSIVE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.defensiveRebounds',
    labelTranslationKey: 'basketball.stats.labels.defensiveRebounds',
  },
  {
    key: STAT_KEYS.REBOUNDS_OFFENSIVE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.offensiveRebounds',
    labelTranslationKey: 'basketball.stats.labels.offensiveRebounds',
  },
  {
    key: STAT_KEYS.STEALS,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.steals',
    labelTranslationKey: 'basketball.stats.labels.steals',
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOAL_PERCENTAGE,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointPercentage',
    labelTranslationKey:
      'basketball.stats.labels.threePointFieldGoalPercentage',
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOALS_ATTEMPTED,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointsAttempted',
    labelTranslationKey:
      'basketball.stats.labels.threePointFieldGoalsAttempted',
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOALS_MISSED,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointsMissed',
    labelTranslationKey: 'basketball.stats.labels.threePointFieldGoalsMissed',
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOALS_MADE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.BASIC, BASKETBALL_VIEWS.MEDIUM],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.threePoints',
    labelTranslationKey: 'basketball.stats.labels.threePointFieldGoalsMade',
  },
  {
    key: STAT_KEYS.TURNOVERS,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM],
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
    (stat) =>
      stat.type === STAT_TYPES.MANUAL && stat.view.includes(currentView as any),
  );
};
