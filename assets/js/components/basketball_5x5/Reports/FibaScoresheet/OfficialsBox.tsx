import React from 'react';
import { useTranslation } from 'react-i18next';
import { Text, View, StyleSheet, Image } from '@react-pdf/renderer';
import { Official } from '../FibaScoresheet';
import { BLUE } from './styles';

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
        position: 'relative',
        minHeight: '18px',
        content: {
          width: '100%',
          maxLines: 2,
        },
        unused: {
          position: 'absolute',
          top: '8px',
          width: '100%',
          height: '2px',
          borderTop: `2px solid ${BLUE}`,
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
  isGameEnded: boolean;
}

function OfficialsBox({
  scorer,
  assistantScorer,
  timekeeper,
  shotClockOperator,
  isGameEnded,
}: OfficialsBoxProps) {
  const { t } = useTranslation();
  return (
    <View style={styles.officialsBox}>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>{t('basketball.reports.fibaScoresheet.officials.scorer')}</Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          {scorer.name ? (
            <Text style={styles.officialsBox.row.name.content}>
              {scorer.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.officialsBox.row.name.unused} />
          ) : null}
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
          {timekeeper.name ? (
            <Text style={styles.officialsBox.row.name.content}>
              {timekeeper.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.officialsBox.row.name.unused} />
          ) : null}
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
          {shotClockOperator.name ? (
            <Text style={styles.officialsBox.row.name.content}>
              {shotClockOperator.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.officialsBox.row.name.unused} />
          ) : null}
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
          {assistantScorer.name ? (
            <Text style={styles.officialsBox.row.name.content}>
              {assistantScorer.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.officialsBox.row.name.unused} />
          ) : null}
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
