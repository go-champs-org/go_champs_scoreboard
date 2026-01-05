import React from 'react';
import { View, Text } from '@react-pdf/renderer';
import { Team } from '../FibaBoxScore';
import { useTranslation } from 'react-i18next';

const styles = {
  scorePerPeriodContainer: {
    marginTop: 10,
    marginBottom: 10,
    fontWeight: 'bold',
    scoreRow: {
      flexDirection: 'row',
      marginBottom: 2,
      scoreNameColumn: {
        width: 100,
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        maxLines: 1,
      },
      scoreValueColumn: {
        textAlign: 'center',
        width: 40,
      },
    },
  },
};

interface ScorePerPeriodProps {
  homeTeam: Team;
  awayTeam: Team;
}

function ScorePerPeriod({ homeTeam, awayTeam }: ScorePerPeriodProps) {
  const { t } = useTranslation();
  const periods = ['1', '2', '3', '4'];
  const maxPeriods = Math.max(
    Object.keys(homeTeam.points_by_period || {}).length,
    Object.keys(awayTeam.points_by_period || {}).length,
  );
  const extraTimePeriods = maxPeriods > 4 ? maxPeriods - 4 : 0;
  const homeTeamExtraTimeScore = Object.keys(homeTeam.points_by_period || {})
    .filter((period) => parseInt(period) > 4)
    .reduce((acc, period) => homeTeam.points_by_period[period] + acc, 0);
  const awayTeamExtraTimeScore = Object.keys(awayTeam.points_by_period || {})
    .filter((period) => parseInt(period) > 4)
    .reduce((acc, period) => awayTeam.points_by_period[period] + acc, 0);
  return (
    <View style={styles.scorePerPeriodContainer}>
      <View style={styles.scorePerPeriodContainer.scoreRow}>
        <Text style={styles.scorePerPeriodContainer.scoreRow.scoreNameColumn}>
          {t('basketball.reports.fibaBoxScore.scorePerPeriod')}
        </Text>
        {periods.map((_, index) => (
          <Text
            key={index}
            style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}
          >
            {index + 1}
          </Text>
        ))}
        {extraTimePeriods > 0 && (
          <Text
            style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}
          >
            {t('basketball.reports.fibaBoxScore.overtimeAbbreviation')}
          </Text>
        )}
        <Text style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}>
          {t('basketball.reports.fibaBoxScore.final')}
        </Text>
      </View>
      <View style={styles.scorePerPeriodContainer.scoreRow}>
        <Text style={styles.scorePerPeriodContainer.scoreRow.scoreNameColumn}>
          {homeTeam.name}
        </Text>
        {homeTeam.points_by_period &&
          periods.map((period, index) => (
            <Text
              key={index}
              style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}
            >
              {homeTeam.points_by_period[period] || 0}
            </Text>
          ))}
        {extraTimePeriods > 0 && (
          <Text
            style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}
          >
            {homeTeamExtraTimeScore}
          </Text>
        )}
        <Text style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}>
          {homeTeam.total_points}
        </Text>
      </View>
      <View style={styles.scorePerPeriodContainer.scoreRow}>
        <Text style={styles.scorePerPeriodContainer.scoreRow.scoreNameColumn}>
          {awayTeam.name}
        </Text>
        {awayTeam.points_by_period &&
          periods.map((period, index) => (
            <Text
              key={index}
              style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}
            >
              {awayTeam.points_by_period[period] === null
                ? '-'
                : awayTeam.points_by_period[period] || 0}
            </Text>
          ))}
        {extraTimePeriods > 0 && (
          <Text
            style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}
          >
            {awayTeamExtraTimeScore}
          </Text>
        )}
        <Text style={styles.scorePerPeriodContainer.scoreRow.scoreValueColumn}>
          {awayTeam.total_points}
        </Text>
      </View>
    </View>
  );
}

export default ScorePerPeriod;
