import React from 'react';
import { View, Text } from '@react-pdf/renderer';
import { useTranslation } from 'react-i18next';
import { boxScorePlayerStats } from '../../selectors';
import { Team } from '../FibaBoxScore';

const ROW_EVEN_BG_COLOR = '#cccccc';
const ROW_ODD_BG_COLOR = '#ffffff';

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
    headerRow: {
      flexDirection: 'row',
      borderTop: '1pt solid black',
      borderLeft: '1pt solid black',
      borderRight: '1pt solid black',
      borderBottom: '2pt solid black',
    },
    playerRow: {
      flexDirection: 'row',
      borderBottom: '1pt solid black',
      borderRight: '1pt solid black',
      borderLeft: '1pt solid black',
    },
    footerRow: {
      flexDirection: 'row',
      borderLeft: '1pt solid black',
      borderRight: '1pt solid black',
      borderBottom: '2pt solid black',
    },
    numberColumn: {
      width: 15,
      verticalAlign: 'middle',
      textAlign: 'left',
      margin: 'auto',
      padding: '1pt',
    },
    nameColumn: {
      width: 130,
      height: '100%',
      display: 'flex',
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'flex-start',
      borderLeft: '1pt solid black',
      content: {
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        maxLines: 1,
      },
      padding: '1pt 0 1pt 2pt',
    },
    statsColumn: {
      width: 28,
      borderLeft: '1pt solid black',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      textAlign: 'center',
      padding: '1pt 0',
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
        <View style={styles.table.headerRow}>
          <Text
            style={{
              ...styles.table.numberColumn,
              padding: '2pt 0 2pt 2pt',
            }}
          >
            #
          </Text>
          <View
            style={{ ...styles.table.nameColumn, padding: '2pt 0 2pt 2pt' }}
          >
            <Text style={styles.table.nameColumn.content}>
              {t('basketball.reports.fibaBoxScore.playerName')}
            </Text>
          </View>
          {playerStats.map((stat, index) => (
            <View
              key={index}
              style={{ ...styles.table.statsColumn, padding: '2pt 1pt' }}
            >
              <Text>{t(stat.abbreviationTranslationKey)}</Text>
            </View>
          ))}
        </View>
        {team.players.map((player, index) => (
          <View
            key={index}
            style={{
              ...styles.table.playerRow,
              borderBottom:
                index === team.players.length - 1
                  ? '2pt solid black'
                  : '1pt solid black',
              backgroundColor:
                index % 2 === 0 ? ROW_EVEN_BG_COLOR : ROW_ODD_BG_COLOR,
            }}
          >
            <Text style={styles.table.numberColumn}>{player.number}</Text>
            <View style={styles.table.nameColumn}>
              <Text style={styles.table.nameColumn.content}>{player.name}</Text>
            </View>
            {playerStats.map((stat, statIndex) => (
              <View key={statIndex} style={styles.table.statsColumn}>
                <CellValue
                  statSlug={stat.key}
                  value={player.stats_values[stat.key] || 0}
                />
              </View>
            ))}
          </View>
        ))}
        <View style={styles.table.footerRow}>
          <View
            style={{ ...styles.table.numberColumn, padding: '2pt 0' }}
          ></View>
          <View
            style={{ ...styles.table.nameColumn, padding: '2pt 0 2pt 2pt' }}
          >
            <Text>{t('basketball.reports.fibaBoxScore.totals')}</Text>
          </View>
          <View style={{ ...styles.table.statsColumn, padding: '2pt 0' }}>
            -
          </View>
          {playerStats
            .filter((stat) => stat.key !== 'minutes_played')
            .map((stat, statIndex) => (
              <View key={statIndex} style={styles.table.statsColumn}>
                <Text>{team.total_player_stats[stat.key] || '-'}</Text>
              </View>
            ))}
        </View>
      </View>
    </View>
  );
}

export default TeamBoxScore;
