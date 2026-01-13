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
  EVENT_KEYS.REGISTER_TEAM_WO,
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

// Team stat keys constant for semantic ordering and reference
export const TEAM_STAT_KEYS = {
  // Manual team stats
  TIMEOUTS: 'timeouts',
  LOST_TIMEOUTS: 'lost_timeouts',
  FOULS_TECHNICAL: 'fouls_technical',

  // Calculated team stats
  POINTS: 'points',
  FOULS: 'fouls',
  TOTAL_FOULS_TECHNICAL: 'total_fouls_technical',
} as const;

// Coach stat keys constant for semantic ordering and reference
export const COACH_STAT_KEYS = {
  // Foul stats
  FOULS_TECHNICAL: 'fouls_technical',
  FOULS_DISQUALIFYING: 'fouls_disqualifying',
  FOULS_DISQUALIFYING_FIGHTING: 'fouls_disqualifying_fighting',
  FOULS_TECHNICAL_BENCH: 'fouls_technical_bench',
  FOULS_TECHNICAL_BENCH_DISQUALIFYING: 'fouls_technical_bench_disqualifying',
  FOULS_GAME_DISQUALIFYING: 'fouls_game_disqualifying',

  // Calculated stats
  FOULS: 'fouls',
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
  MEDIUM_PLUS: 'basketball-medium-plus',
} as const;

export interface PlayerStat {
  key: string;
  type: (typeof STAT_TYPES)[keyof typeof STAT_TYPES];
  view: BasketballViews[];
  abbreviationTranslationKey: string;
  descriptionTranslationKey: string;
  labelTranslationKey: string;
  boxScoreMetadata?: {
    displayInBoxScore: boolean;
    boxScoreOrder?: number;
  };
}

export const PLAYER_STATS: PlayerStat[] = [
  {
    key: STAT_KEYS.ASSISTS,
    type: STAT_TYPES.MANUAL,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.assists',
    labelTranslationKey: 'basketball.stats.labels.assists',
    descriptionTranslationKey: 'basketball.stats.descriptions.assists',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 4,
    },
  },
  {
    key: STAT_KEYS.BLOCKS,
    type: STAT_TYPES.MANUAL,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.blocks',
    labelTranslationKey: 'basketball.stats.labels.blocks',
    descriptionTranslationKey: 'basketball.stats.descriptions.blocks',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 6,
    },
  },
  {
    key: STAT_KEYS.EFFICIENCY,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.efficiency',
    labelTranslationKey: 'basketball.stats.labels.efficiency',
    descriptionTranslationKey: 'basketball.stats.descriptions.efficiency',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 20,
    },
  },
  {
    key: STAT_KEYS.FIELD_GOAL_PERCENTAGE,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalPercentage',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalPercentage',
    descriptionTranslationKey:
      'basketball.stats.descriptions.fieldGoalPercentage',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FIELD_GOALS_ATTEMPTED,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalsAttempted',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsAttempted',
    descriptionTranslationKey:
      'basketball.stats.descriptions.fieldGoalsAttempted',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 10,
    },
  },
  {
    key: STAT_KEYS.FIELD_GOALS_MISSED,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.fieldGoalsMissed',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsMissed',
    descriptionTranslationKey: 'basketball.stats.descriptions.fieldGoalsMissed',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FIELD_GOALS_MADE,
    type: STAT_TYPES.MANUAL,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.fieldGoalsMade',
    labelTranslationKey: 'basketball.stats.labels.fieldGoalsMade',
    descriptionTranslationKey: 'basketball.stats.descriptions.fieldGoalsMade',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 9,
    },
  },
  {
    key: STAT_KEYS.FOULS,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.fouls',
    labelTranslationKey: 'basketball.stats.labels.fouls',
    descriptionTranslationKey: 'basketball.stats.descriptions.fouls',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 19,
    },
  },
  {
    key: STAT_KEYS.FOULS_UNSPORTSMANLIKE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.unsportsmanlikeFouls',
    labelTranslationKey: 'basketball.stats.labels.unsportsmanlikeFouls',
    descriptionTranslationKey:
      'basketball.stats.descriptions.unsportsmanlikeFouls',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FOULS_PERSONAL,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.personalFouls',
    labelTranslationKey: 'basketball.stats.labels.personalFouls',
    descriptionTranslationKey: 'basketball.stats.descriptions.personalFouls',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FOULS_TECHNICAL,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.technicalFouls',
    labelTranslationKey: 'basketball.stats.labels.technicalFouls',
    descriptionTranslationKey: 'basketball.stats.descriptions.technicalFouls',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FOULS_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.disqualifyingFouls',
    labelTranslationKey: 'basketball.stats.labels.disqualifyingFouls',
    descriptionTranslationKey:
      'basketball.stats.descriptions.disqualifyingFouls',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FOULS_DISQUALIFYING_FIGHTING,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.disqualifyingFightingFouls',
    labelTranslationKey: 'basketball.stats.labels.disqualifyingFightingFouls',
    descriptionTranslationKey:
      'basketball.stats.descriptions.disqualifyingFightingFouls',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FOULS_GAME_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.gameDisqualifyingFouls',
    labelTranslationKey: 'basketball.stats.labels.gameDisqualifyingFouls',
    descriptionTranslationKey:
      'basketball.stats.descriptions.gameDisqualifyingFouls',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FREE_THROW_PERCENTAGE,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.onePointPercentage',
    labelTranslationKey: 'basketball.stats.labels.freeThrowPercentage',
    descriptionTranslationKey:
      'basketball.stats.descriptions.freeThrowPercentage',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FREE_THROWS_ATTEMPTED,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.freeThrowsAttempted',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsAttempted',
    descriptionTranslationKey:
      'basketball.stats.descriptions.freeThrowsAttempted',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 8,
    },
  },
  {
    key: STAT_KEYS.FREE_THROWS_MISSED,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.freeThrowsMissed',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsMissed',
    descriptionTranslationKey: 'basketball.stats.descriptions.freeThrowsMissed',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.FREE_THROWS_MADE,
    type: STAT_TYPES.MANUAL,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.onePoint',
    labelTranslationKey: 'basketball.stats.labels.freeThrowsMade',
    descriptionTranslationKey: 'basketball.stats.descriptions.freeThrowsMade',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 7,
    },
  },
  {
    key: STAT_KEYS.MINUTES_PLAYED,
    type: STAT_TYPES.AUTOMATIC,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.minutesPlayed',
    labelTranslationKey: 'basketball.stats.labels.minutesPlayed',
    descriptionTranslationKey: 'basketball.stats.descriptions.minutesPlayed',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 1,
    },
  },
  {
    key: STAT_KEYS.PLUS_MINUS,
    type: STAT_TYPES.AUTOMATIC,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.plusMinus',
    labelTranslationKey: 'basketball.stats.labels.plusMinus',
    descriptionTranslationKey: 'basketball.stats.descriptions.plusMinus',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.POINTS,
    type: STAT_TYPES.CALCULATED,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.points',
    labelTranslationKey: 'basketball.stats.labels.points',
    descriptionTranslationKey: 'basketball.stats.descriptions.points',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 2,
    },
  },
  {
    key: STAT_KEYS.REBOUNDS,
    type: STAT_TYPES.CALCULATED,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.rebounds',
    labelTranslationKey: 'basketball.stats.labels.rebounds',
    descriptionTranslationKey: 'basketball.stats.descriptions.rebounds',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 3,
    },
  },
  {
    key: STAT_KEYS.REBOUNDS_DEFENSIVE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.defensiveRebounds',
    labelTranslationKey: 'basketball.stats.labels.defensiveRebounds',
    descriptionTranslationKey:
      'basketball.stats.descriptions.defensiveRebounds',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 16,
    },
  },
  {
    key: STAT_KEYS.REBOUNDS_OFFENSIVE,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.offensiveRebounds',
    labelTranslationKey: 'basketball.stats.labels.offensiveRebounds',
    descriptionTranslationKey:
      'basketball.stats.descriptions.offensiveRebounds',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 17,
    },
  },
  {
    key: STAT_KEYS.STEALS,
    type: STAT_TYPES.MANUAL,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.steals',
    labelTranslationKey: 'basketball.stats.labels.steals',
    descriptionTranslationKey: 'basketball.stats.descriptions.steals',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 5,
    },
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOAL_PERCENTAGE,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointPercentage',
    labelTranslationKey:
      'basketball.stats.labels.threePointFieldGoalPercentage',
    descriptionTranslationKey:
      'basketball.stats.descriptions.threePointFieldGoalPercentage',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOALS_ATTEMPTED,
    type: STAT_TYPES.CALCULATED,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointsAttempted',
    labelTranslationKey:
      'basketball.stats.labels.threePointFieldGoalsAttempted',
    descriptionTranslationKey:
      'basketball.stats.descriptions.threePointFieldGoalsAttempted',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 13,
    },
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOALS_MISSED,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey:
      'basketball.stats.abbreviations.threePointsMissed',
    labelTranslationKey: 'basketball.stats.labels.threePointFieldGoalsMissed',
    descriptionTranslationKey:
      'basketball.stats.descriptions.threePointFieldGoalsMissed',
    boxScoreMetadata: {
      displayInBoxScore: false,
    },
  },
  {
    key: STAT_KEYS.THREE_POINT_FIELD_GOALS_MADE,
    type: STAT_TYPES.MANUAL,
    view: [
      BASKETBALL_VIEWS.BASIC,
      BASKETBALL_VIEWS.MEDIUM,
      BASKETBALL_VIEWS.MEDIUM_PLUS,
    ],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.threePoints',
    labelTranslationKey: 'basketball.stats.labels.threePointFieldGoalsMade',
    descriptionTranslationKey:
      'basketball.stats.descriptions.threePointFieldGoalsMade',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 12,
    },
  },
  {
    key: STAT_KEYS.TURNOVERS,
    type: STAT_TYPES.MANUAL,
    view: [BASKETBALL_VIEWS.MEDIUM, BASKETBALL_VIEWS.MEDIUM_PLUS],
    abbreviationTranslationKey: 'basketball.stats.abbreviations.turnovers',
    labelTranslationKey: 'basketball.stats.labels.turnovers',
    descriptionTranslationKey: 'basketball.stats.descriptions.turnovers',
    boxScoreMetadata: {
      displayInBoxScore: true,
      boxScoreOrder: 19,
    },
  },
] as const;

export const TEAM_STATS = [
  {
    key: TEAM_STAT_KEYS.TIMEOUTS,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey: 'basketball.teamStats.abbreviations.timeouts',
    labelTranslationKey: 'basketball.teamStats.labels.timeouts',
  },
  {
    key: TEAM_STAT_KEYS.LOST_TIMEOUTS,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.teamStats.abbreviations.lostTimeouts',
    labelTranslationKey: 'basketball.teamStats.labels.lostTimeouts',
  },
  {
    key: TEAM_STAT_KEYS.FOULS_TECHNICAL,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.teamStats.abbreviations.technicalFouls',
    labelTranslationKey: 'basketball.teamStats.labels.technicalFouls',
  },
  {
    key: TEAM_STAT_KEYS.POINTS,
    type: STAT_TYPES.CALCULATED,
    abbreviationTranslationKey: 'basketball.teamStats.abbreviations.points',
    labelTranslationKey: 'basketball.teamStats.labels.points',
  },
  {
    key: TEAM_STAT_KEYS.FOULS,
    type: STAT_TYPES.CALCULATED,
    abbreviationTranslationKey: 'basketball.teamStats.abbreviations.fouls',
    labelTranslationKey: 'basketball.teamStats.labels.fouls',
  },
  {
    key: TEAM_STAT_KEYS.TOTAL_FOULS_TECHNICAL,
    type: STAT_TYPES.CALCULATED,
    abbreviationTranslationKey:
      'basketball.teamStats.abbreviations.totalTechnicalFouls',
    labelTranslationKey: 'basketball.teamStats.labels.totalTechnicalFouls',
  },
] as const;

export const COACH_STATS = [
  {
    key: COACH_STAT_KEYS.FOULS_TECHNICAL,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.coachStats.abbreviations.technicalFouls',
    labelTranslationKey: 'basketball.coachStats.labels.technicalFouls',
  },
  {
    key: COACH_STAT_KEYS.FOULS_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.coachStats.abbreviations.disqualifyingFouls',
    labelTranslationKey: 'basketball.coachStats.labels.disqualifyingFouls',
  },
  {
    key: COACH_STAT_KEYS.FOULS_DISQUALIFYING_FIGHTING,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.coachStats.abbreviations.disqualifyingFightingFouls',
    labelTranslationKey:
      'basketball.coachStats.labels.disqualifyingFightingFouls',
  },
  {
    key: COACH_STAT_KEYS.FOULS_TECHNICAL_BENCH,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.coachStats.abbreviations.technicalBenchFouls',
    labelTranslationKey: 'basketball.coachStats.labels.technicalBenchFouls',
  },
  {
    key: COACH_STAT_KEYS.FOULS_TECHNICAL_BENCH_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.coachStats.abbreviations.technicalBenchDisqualifyingFouls',
    labelTranslationKey:
      'basketball.coachStats.labels.technicalBenchDisqualifyingFouls',
  },
  {
    key: COACH_STAT_KEYS.FOULS_GAME_DISQUALIFYING,
    type: STAT_TYPES.MANUAL,
    abbreviationTranslationKey:
      'basketball.coachStats.abbreviations.gameDisqualifyingFouls',
    labelTranslationKey: 'basketball.coachStats.labels.gameDisqualifyingFouls',
  },
  {
    key: COACH_STAT_KEYS.FOULS,
    type: STAT_TYPES.CALCULATED,
    abbreviationTranslationKey: 'basketball.coachStats.abbreviations.fouls',
    labelTranslationKey: 'basketball.coachStats.labels.fouls',
  },
] as const;

// Utility function to get manual player stats for a specific view
export const getManualPlayerStatsForView = (currentView: BasketballViews) => {
  return PLAYER_STATS.filter(
    (stat) =>
      stat.type === STAT_TYPES.MANUAL && stat.view.includes(currentView as any),
  );
};
