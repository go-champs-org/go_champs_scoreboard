import React from 'react';
import { useTranslation } from 'react-i18next';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { BLUE } from './styles';

const styles = StyleSheet.create({
  headerBox: {
    display: 'flex',
    flex: '1',
    padding: '3px',
    row: {
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'space-between',
      flex: '1 1 auto',
      column: {
        flex: '1',
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        label: {
          width: '45px',
        },
        value: {
          flex: '1',
          alignItems: 'start',
          justifyContent: 'start',
          padding: '0 5px',
          overflow: 'hidden',
          position: 'relative',
          minHeight: '10px',
          content: {
            width: '100%',
            maxLines: 1,
            textOverflow: 'ellipsis',
          },
          unused: {
            position: 'absolute',
            top: '4px',
            width: '100%',
            height: '2px',
            borderTop: `2px solid ${BLUE}`,
          },
        },
      },
    },
  },
});

interface HeaderBoxProps {
  location: string;
  datetime: string;
  number: string;
  city: string;
  crewChiefName: string;
  umpire1Name: string;
  umpire2Name: string;
  teamAName: string;
  teamBName: string;
  isGameEnded: boolean;
}

function HeaderBox({
  number,
  crewChiefName,
  umpire1Name,
  umpire2Name,
  location,
  city,
  datetime,
  teamAName,
  teamBName,
  isGameEnded = false,
}: HeaderBoxProps) {
  const { t } = useTranslation();
  const date = new Date(datetime).toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  });
  const time = new Date(datetime).toLocaleTimeString('pt-BR', {
    hour: '2-digit',
    minute: '2-digit',
  });
  return (
    <View style={styles.headerBox}>
      {/* Row 1: Location | Date | Game Number */}
      <View style={styles.headerBox.row}>
        <View style={{ ...styles.headerBox.row.column, maxWidth: '170px' }}>
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.location')}:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {location}
            </Text>
          </View>
        </View>
        <View style={{ ...styles.headerBox.row.column, flex: '0.6' }}>
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.date')}:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>{date}</Text>
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1.4',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.team')} A:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {teamAName}
            </Text>
          </View>
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.team')} B:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {teamBName}
            </Text>
          </View>
        </View>
      </View>

      {/* Row 2: City | Time | Game Nro. */}
      <View style={styles.headerBox.row}>
        <View style={{ ...styles.headerBox.row.column, maxWidth: '170px' }}>
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.city')}:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {city || ''}
            </Text>
          </View>
        </View>
        <View style={{ ...styles.headerBox.row.column, flex: '0.6' }}>
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.time')}:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>{time}</Text>
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1.4',
            width: '100px',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>{t('basketball.reports.fibaScoresheet.gameNumber')}:</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>{number}</Text>
          </View>
        </View>
      </View>

      {/* Row 3: Officials */}
      <View style={styles.headerBox.row}>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>
              {t('basketball.reports.fibaScoresheet.officials.crewChief')}:
            </Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            {crewChiefName ? (
              <Text style={styles.headerBox.row.column.value.content}>
                {crewChiefName}
              </Text>
            ) : isGameEnded ? (
              <View style={styles.headerBox.row.column.value.unused} />
            ) : null}
          </View>
        </View>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>
              {t('basketball.reports.fibaScoresheet.officials.umpire1')}:
            </Text>
          </View>

          <View style={styles.headerBox.row.column.value}>
            {umpire1Name ? (
              <Text style={styles.headerBox.row.column.value.content}>
                {umpire1Name}
              </Text>
            ) : isGameEnded ? (
              <View style={styles.headerBox.row.column.value.unused} />
            ) : null}
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1 0 auto',
            width: '50px',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>
              {t('basketball.reports.fibaScoresheet.officials.umpire2')}:
            </Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            {umpire2Name ? (
              <Text style={styles.headerBox.row.column.value.content}>
                {umpire2Name}
              </Text>
            ) : isGameEnded ? (
              <View style={styles.headerBox.row.column.value.unused} />
            ) : null}
          </View>
        </View>
      </View>
    </View>
  );
}

export default HeaderBox;
