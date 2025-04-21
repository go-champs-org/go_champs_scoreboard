import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';

const styles = StyleSheet.create({
  fiscalsBox: {
    display: 'flex',
    flexDirection: 'column',
    flex: '1 1',
    padding: '3px',
    borderTop: '1px solid #000',
    maxHeight: '40px',
    row: {
      display: 'flex',
      flexDirection: 'row',
      flex: '1 1 auto',
      column: {
        flex: '1 1',
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
      },
      label: {
        flex: '1 1 auto',
        maxWidth: '38%',
      },
      signatureBox: {
        flex: '1 1 auto',
        borderBottom: '1px solid #000',
        height: '20px',
      },
    },
  },
});

function FiscalsBox() {
  return (
    <View style={styles.fiscalsBox}>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.column}>
          <Text style={styles.fiscalsBox.row.label}>Crew Chief</Text>
          <View style={styles.fiscalsBox.row.signatureBox}></View>
        </View>
        <View style={styles.fiscalsBox.row.column}></View>
      </View>
      <View style={styles.fiscalsBox.row}>
        <View style={styles.fiscalsBox.row.column}>
          <Text style={styles.fiscalsBox.row.label}>Fiscal 1</Text>
          <View style={styles.fiscalsBox.row.signatureBox}></View>
        </View>
        <View style={styles.fiscalsBox.row.column}>
          <Text style={styles.fiscalsBox.row.label}>Fiscal 2</Text>
          <View style={styles.fiscalsBox.row.signatureBox}></View>
        </View>
      </View>
    </View>
  );
}

export default FiscalsBox;
