import React from 'react';
import { useTranslation } from 'react-i18next';
import { Text, View, StyleSheet, Image } from '@react-pdf/renderer';
import { Official } from '../FibaScoresheet';

const styles = StyleSheet.create({
  officialsBox: {
    display: 'flex',
    flexDirection: 'column',
    flex: '1 1',
    padding: '2px',
    borderTop: '1px solid #000',
    borderBottom: '1px solid #000',
    maxHeight: '80px',
    row: {
      display: 'flex',
      flexDirection: 'row',
      flex: '1 1 auto',
      label: {
        alingItems: 'center',
        justifyContent: 'center',
        width: '60px',
      },
      name: {
        flex: '1',
        alingItems: 'center',
        justifyContent: 'center',
        padding: '0 5px',
        width: '80px',
        overflow: 'hidden',
        content: {
          width: '100%',
          maxLines: 2,
        },
      },
      signatureBox: {
        borderBottom: '1px solid #000',
        flex: '0 1 60px',
        height: '18px',
      },
    },
  },
});

interface OfficialsBoxProps {
  scorer: Official;
  assistantScorer: Official;
  timekeeper: Official;
  shotClockOperator: Official;
}

function OfficialsBox({
  scorer,
  assistantScorer,
  timekeeper,
  shotClockOperator,
}: OfficialsBoxProps) {
  const { t } = useTranslation();
  return (
    <View style={styles.officialsBox}>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>{t('basketball.reports.fibaScoresheet.officials.scorer')}</Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            {scorer.name}
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}>
          {scorer.signature && (
            <Image
              src={scorer.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>
            {t('basketball.reports.fibaScoresheet.officials.timekeeper')}
          </Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            {timekeeper.name}
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}>
          {timekeeper.signature && (
            <Image
              src={timekeeper.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>
            {t('basketball.reports.fibaScoresheet.officials.shotClockOperator')}
          </Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            {shotClockOperator.name}
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}>
          {shotClockOperator.signature && (
            <Image
              src={shotClockOperator.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>
            {t('basketball.reports.fibaScoresheet.officials.assistantScorer')}
          </Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            {assistantScorer.name}
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}>
          {assistantScorer.signature && (
            <Image
              src={assistantScorer.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
    </View>
  );
}

export default OfficialsBox;
