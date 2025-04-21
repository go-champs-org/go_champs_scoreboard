import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';

const styles = StyleSheet.create({
  officialsBox: {
    display: 'flex',
    flexDirection: 'column',
    flex: '1 1',
    padding: '3px',
    borderTop: '1px solid #000',
    borderBottom: '1px solid #000',
    maxHeight: '100px',
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
        height: '20px',
      },
    },
  },
});

function OfficialsBox() {
  return (
    <View style={styles.officialsBox}>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>Apontador</Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            CLERBERA ASDAS DA ADAS DASD ASD ASD ASD ASD ASD ASD ASD ASD
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}></View>
      </View>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>Cronometrista</Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            CLERBERA ASDAS
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}></View>
      </View>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>Operador 24s</Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            CLERBERA ASDAS 1234 5678 9012 345 asd asd asd as d123 234 54 000 123
            123 123
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}></View>
      </View>
      <View style={styles.officialsBox.row}>
        <View style={styles.officialsBox.row.label}>
          <Text>Comissário</Text>
        </View>
        <View style={styles.officialsBox.row.name}>
          <Text style={styles.officialsBox.row.name.content}>
            CLERBERA ASDAS DA ADAS DASD ASD ASD ASD ASD ASD ASD ASD ASD
          </Text>
        </View>
        <View style={styles.officialsBox.row.signatureBox}></View>
      </View>
    </View>
  );
}

export default OfficialsBox;
