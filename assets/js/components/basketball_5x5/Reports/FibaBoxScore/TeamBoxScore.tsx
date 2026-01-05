import React from 'react';
import { View, Text } from '@react-pdf/renderer';
import { useTranslation } from 'react-i18next';
import { boxScorePlayerStats } from '../../selectors';
import { t } from 'i18next';
import { Team } from '../FibaBoxScore';

function TimeStatCell({ value }: { value: number }) {
  const minutes = Math.floor(value / 60);
  const seconds = value % 60;
  const formattedTime = `${minutes}:${seconds.toString().padStart(2, '0')}`;
  return <Text>{value ? formattedTime : '-'}</Text>;
}

function DefaultStatCell({ value }: { value: string }) {
  return <Text>{value ? value : '-'}</Text>;
}

function CellValue({ statSlug, value }: { statSlug: string; value: number }) {
  if (statSlug === 'minutes_played') {
    return <TimeStatCell value={value} />;
  } else {
    return <DefaultStatCell value={value.toString()} />;
  }
}

const styles = {
  name: {
    fontSize: 10,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  table: {
    display: 'table',
    width: 'auto',
    borderStyle: 'solid',
    fontWeight: 'bold',
    numberColumn: {
      width: 15,
      verticalAlign: 'middle',
      textAlign: 'left',
      margin: 'auto',
    },
    nameColumn: {
      width: 130,
      verticalAlign: 'middle',
      textAlign: 'left',
      margin: 'auto',
      textOverflow: 'ellipsis',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
      maxLines: 1,
    },
    statsColumn: {
      width: 28,
      textAlign: 'center',
      verticalAlign: 'middle',
      margin: 'auto',
    },
  },
};

interface TeamBoxScoreProps {
  teamType: 'home' | 'away';
  team: Team;
}

function TeamBoxScore({ teamType, team }: TeamBoxScoreProps) {
  const { t } = useTranslation();
  const teamLabel =
    teamType === 'home'
      ? t('basketball.teams.teamA')
      : t('basketball.teams.teamB');
  const playerStats = boxScorePlayerStats();
  return (
    <View style={{ marginBottom: 8, marginTop: 8 }}>
      <View style={styles.name}>
        <Text>{`${teamLabel}: ${team.name}`}</Text>
      </View>
      <View style={styles.table}>
        <View
          style={{
            flexDirection: 'row',
            borderBottom: '1pt solid black',
            marginBottom: 4,
          }}
        >
          <Text style={styles.table.numberColumn}>#</Text>
          <Text style={styles.table.nameColumn}>Name</Text>
          {playerStats.map((stat, index) => (
            <Text key={index} style={styles.table.statsColumn}>
              {t(stat.abbreviationTranslationKey)}
            </Text>
          ))}
        </View>
        {team.players.map((player, index) => (
          <View key={index} style={{ flexDirection: 'row', marginBottom: 2 }}>
            <Text style={styles.table.numberColumn}>{player.number}</Text>
            <Text style={styles.table.nameColumn}>{player.name}</Text>
            {playerStats.map((stat, statIndex) => (
              <Text key={statIndex} style={styles.table.statsColumn}>
                <CellValue
                  statSlug={stat.key}
                  value={player.stats_values[stat.key] || 0}
                />
              </Text>
            ))}
          </View>
        ))}
        <View style={{ flexDirection: 'row', marginBottom: 2 }}>
          <Text style={styles.table.numberColumn}></Text>
          <Text style={styles.table.nameColumn}>
            {t('basketball.reports.fibaBoxScore.totals')}
          </Text>
          <Text style={styles.table.statsColumn}>-</Text>
          {playerStats
            .filter((stat) => stat.key !== 'minutes_played')
            .map((stat, statIndex) => (
              <Text key={statIndex} style={styles.table.statsColumn}>
                {team.total_player_stats[stat.key] || '-'}
              </Text>
            ))}
        </View>
      </View>
    </View>
  );
}

export default TeamBoxScore;
