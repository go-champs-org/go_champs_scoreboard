import React from 'react';
import { View, Text } from '@react-pdf/renderer';
import { useTranslation } from 'react-i18next';

const styles = {
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
    fontWeight: 'bold',
    infoItem: {
      flexDirection: 'column',
    },
  },
};

interface GameInfoProps {
  gameNumber: string;
  date: string;
  startTime: string;
  endTime: string;
  venue: string;
}

function GameInfo({
  gameNumber,
  date,
  startTime,
  endTime,
  venue,
}: GameInfoProps) {
  const { t } = useTranslation();
  const formattedDate = new Date(date).toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  });
  const startAt = new Date(startTime).toLocaleTimeString('pt-BR', {
    hour: '2-digit',
    minute: '2-digit',
  });
  const endAt = new Date(endTime).toLocaleTimeString('pt-BR', {
    hour: '2-digit',
    minute: '2-digit',
  });
  return (
    <View>
      <View style={styles.infoRow}>
        <View style={styles.infoRow.infoItem}>
          <Text>
            {t('basketball.reports.fibaBoxScore.gameNumber')}: {gameNumber}
          </Text>
        </View>
        <View style={styles.infoRow.infoItem}>
          <Text>
            {t('basketball.reports.fibaBoxScore.date')}: {formattedDate}
          </Text>
        </View>
        <View style={styles.infoRow.infoItem}>
          <Text>
            {t('basketball.reports.fibaBoxScore.startAt')}:{' '}
            {startAt === 'Invalid Date' ? '' : startAt}
          </Text>
        </View>
        <View style={styles.infoRow.infoItem}>
          <Text>
            {t('basketball.reports.fibaBoxScore.endAt')}:{' '}
            {endAt === 'Invalid Date' ? '' : endAt}
          </Text>
        </View>
      </View>
      <View style={styles.infoRow}>
        <View style={styles.infoRow.infoItem}>
          <Text>
            {t('basketball.reports.fibaBoxScore.location')}: {venue}
          </Text>
        </View>
      </View>
    </View>
  );
}

export default GameInfo;
