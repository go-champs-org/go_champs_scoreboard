import React from 'react';
import { useTranslation } from 'react-i18next';
import { Text, View, StyleSheet, Image } from '@react-pdf/renderer';
import { Official } from '../FibaScoresheet';
import { BLUE } from './styles';

const styles = StyleSheet.create({
  fiscalsBox: {
    display: 'flex',
    flexDirection: 'column',
    flex: '1 1',
    padding: '2px',
    borderTop: '1px solid #000',
    borderBottom: '1px solid #000',
    maxHeight: '58px',
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
        image: {
          maxHeight: '100%',
          maxWidth: '100%',
          objectFit: 'contain',
        },
      },
    },
  },
});

interface FiscalsBoxProps {
  crewChief: Official;
  umpire1: Official;
  umpire2: Official;
  isGameEnded: boolean;
}

function FiscalsBox({
  crewChief,
  umpire1,
  umpire2,
  isGameEnded,
}: FiscalsBoxProps) {
  const { t } = useTranslation();
  return (
    <View style={styles.fiscalsBox}>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.label}>
          <Text>
            {t('basketball.reports.fibaScoresheet.officials.crewChief')}
          </Text>
        </View>
        <View style={styles.fiscalsBox.row.name}>
          {crewChief.name ? (
            <Text style={styles.fiscalsBox.row.name.content}>
              {crewChief.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.fiscalsBox.row.name.unused} />
          ) : null}
        </View>
        <View style={styles.fiscalsBox.row.signatureBox}>
          {crewChief.signature && (
            <Image
              src={crewChief.signature}
              style={styles.fiscalsBox.row.signatureBox.image}
            />
          )}
        </View>
      </View>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.label}>
          <Text>
            {t('basketball.reports.fibaScoresheet.officials.umpire1')}
          </Text>
        </View>
        <View style={styles.fiscalsBox.row.name}>
          {umpire1.name ? (
            <Text style={styles.fiscalsBox.row.name.content}>
              {umpire1.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.fiscalsBox.row.name.unused} />
          ) : null}
        </View>
        <View style={styles.fiscalsBox.row.signatureBox}>
          {umpire1.signature && (
            <Image
              src={umpire1.signature}
              style={styles.fiscalsBox.row.signatureBox.image}
            />
          )}
        </View>
      </View>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.label}>
          <Text>
            {t('basketball.reports.fibaScoresheet.officials.umpire2')}
          </Text>
        </View>
        <View style={styles.fiscalsBox.row.name}>
          {umpire2.name ? (
            <Text style={styles.fiscalsBox.row.name.content}>
              {umpire2.name}
            </Text>
          ) : isGameEnded ? (
            <View style={styles.fiscalsBox.row.name.unused} />
          ) : null}
        </View>
        <View style={styles.fiscalsBox.row.signatureBox}>
          {umpire2.signature && (
            <Image
              src={umpire2.signature}
              style={styles.fiscalsBox.row.signatureBox.image}
            />
          )}
        </View>
      </View>
    </View>
  );
}

export default FiscalsBox;
