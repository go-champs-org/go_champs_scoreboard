import React from 'react';
import { Text, View, StyleSheet, Image } from '@react-pdf/renderer';
import { Official } from '../FibaScoresheet';

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

interface FiscalsBoxProps {
  crewChief: Official;
  umpire1: Official;
  umpire2: Official;
}

function FiscalsBox({ crewChief, umpire1, umpire2 }: FiscalsBoxProps) {
  return (
    <View style={styles.fiscalsBox}>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.label}>
          <Text>Crew Chief</Text>
        </View>
        <View style={styles.fiscalsBox.row.name}>
          <Text style={styles.fiscalsBox.row.name.content}>
            {crewChief.name}
          </Text>
        </View>
        <View style={styles.fiscalsBox.row.signatureBox}>
          {crewChief.signature && (
            <Image
              src={crewChief.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.label}>
          <Text>Fiscal 1</Text>
        </View>
        <View style={styles.fiscalsBox.row.name}>
          <Text style={styles.fiscalsBox.row.name.content}>{umpire1.name}</Text>
        </View>
        <View style={styles.fiscalsBox.row.signatureBox}>
          {umpire1.signature && (
            <Image
              src={umpire1.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.label}>
          <Text>Fiscal 2</Text>
        </View>
        <View style={styles.fiscalsBox.row.name}>
          <Text style={styles.fiscalsBox.row.name.content}>{umpire2.name}</Text>
        </View>
        <View style={styles.fiscalsBox.row.signatureBox}>
          {umpire2.signature && (
            <Image
              src={umpire2.signature}
              style={{ width: '100%', height: '100%' }}
            />
          )}
        </View>
      </View>
    </View>
  );
}

export default FiscalsBox;
