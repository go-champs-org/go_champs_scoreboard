import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { FibaScoresheetData } from '../FibaScoresheet';

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
          content: {
            width: '100%',
            maxLines: 2,
          },
        },
      },
    },
  },
});

function HeaderBox({ scoresheetData }: { scoresheetData: FibaScoresheetData }) {
  return (
    <View style={styles.headerBox}>
      <View style={styles.headerBox.row}>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Local</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              Dunk Park
            </Text>
          </View>
        </View>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Data</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>14/04/2025</Text>
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1 0 auto',
            width: '60px',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>Jogo Id</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>{scoresheetData.game_id}</Text>
          </View>
        </View>
      </View>
      <View style={styles.headerBox.row}>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Crew Chief</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              cleber grabauska
            </Text>
          </View>
        </View>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Fiscal 1</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              Arnoldo
            </Text>
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1 0 auto',
            width: '60px',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>Fiscal 2</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>Bento</Text>
          </View>
        </View>
      </View>
    </View>
  );
}

export default HeaderBox;
