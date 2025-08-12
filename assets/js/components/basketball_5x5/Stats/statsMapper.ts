const STAT_ID_TO_ABBREVIATION_KEY: { [key: string]: string } = {
  free_throws_made: 'basketball.stats.abbreviations.onePoint',
  free_throws_missed: 'basketball.stats.abbreviations.missOnePoint',
  free_throws_attempted: 'basketball.stats.abbreviations.onePoint',
  free_throw_percentage: 'basketball.stats.abbreviations.onePointPercentage',
  field_goals_made: 'basketball.stats.abbreviations.twoPoints',
  field_goals_missed: 'basketball.stats.abbreviations.missTwoPoints',
  field_goals_attempted: 'basketball.stats.abbreviations.twoPoints',
  field_goal_percentage: 'basketball.stats.abbreviations.twoPointPercentage',
  three_point_field_goals_made: 'basketball.stats.abbreviations.threePoints',
  three_point_field_goals_missed:
    'basketball.stats.abbreviations.missThreePoints',
  three_point_field_goals_attempted:
    'basketball.stats.abbreviations.threePoints',
  three_point_field_goal_percentage:
    'basketball.stats.abbreviations.threePointPercentage',
  assists: 'basketball.stats.abbreviations.assists',
  rebounds_offensive: 'basketball.stats.abbreviations.offensiveRebounds',
  rebounds_defensive: 'basketball.stats.abbreviations.defensiveRebounds',
  steals: 'basketball.stats.abbreviations.steals',
  blocks: 'basketball.stats.abbreviations.blocks',
  turnovers: 'basketball.stats.abbreviations.turnovers',
  fouls_personal: 'basketball.stats.abbreviations.personalFoulsShort',
  fouls_technical: 'basketball.stats.abbreviations.technicalFoulsShort',
  fouls_flagrant: 'basketball.stats.abbreviations.flagrantFoulsShort',
};

export function statIdToAbbreviationKey(statId: string) {
  return STAT_ID_TO_ABBREVIATION_KEY[statId] || '';
}
