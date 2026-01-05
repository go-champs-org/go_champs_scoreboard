import { PLAYER_STATS } from './constants';

export const boxScorePlayerStats = () => {
  return PLAYER_STATS.filter(
    (stat) => stat.boxScoreMetadata?.displayInBoxScore,
  ).sort(
    (a, b) =>
      (a.boxScoreMetadata?.boxScoreOrder || 0) -
      (b.boxScoreMetadata?.boxScoreOrder || 0),
  );
};
