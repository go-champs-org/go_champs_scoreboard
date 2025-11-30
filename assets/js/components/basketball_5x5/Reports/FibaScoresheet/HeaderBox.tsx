import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';

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
          width: '55px',
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

interface HeaderBoxProps {
  location: string;
  datetime: string;
  number: string;
  crewChiefName: string;
  umpire1Name: string;
  umpire2Name: string;
}

function HeaderBox({
  number,
  crewChiefName,
  umpire1Name,
  umpire2Name,
  location,
  datetime,
}: HeaderBoxProps) {
  const date = new Date(datetime).toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    timeZone: 'UTC', // This forces UTC timezone
  });
  const time = new Date(datetime).toLocaleTimeString('pt-BR', {
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'UTC', // This forces UTC timezone
  });
  return (
    <View style={styles.headerBox}>
      <View style={styles.headerBox.row}>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Local</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {location}
            </Text>
          </View>
        </View>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Data - Hora I</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>{`${date} - ${time}`}</Text>
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1 0 auto',
            width: '70px',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>Jogo Id</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text>{number}</Text>
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
              {crewChiefName}
            </Text>
          </View>
        </View>
        <View style={styles.headerBox.row.column}>
          <View style={styles.headerBox.row.column.label}>
            <Text>Fiscal 1</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {umpire1Name}
            </Text>
          </View>
        </View>
        <View
          style={{
            ...styles.headerBox.row.column,
            flex: '1 0 auto',
            width: '70px',
          }}
        >
          <View style={styles.headerBox.row.column.label}>
            <Text>Fiscal 2</Text>
          </View>
          <View style={styles.headerBox.row.column.value}>
            <Text style={styles.headerBox.row.column.value.content}>
              {umpire2Name}
            </Text>
          </View>
        </View>
      </View>
    </View>
  );
}

export default HeaderBox;
