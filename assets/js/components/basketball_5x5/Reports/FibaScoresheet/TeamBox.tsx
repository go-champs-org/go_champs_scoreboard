import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { Team } from '../FibaScoresheet';

const styles = StyleSheet.create({
  teamContainer: {
    borderBottom: '1px solid #000',
    display: 'flex',
    flex: '1 1',
    header: {
      display: 'flex',
      flexDirection: 'column',
      padding: '5px',
      borderBottom: '1px solid #000',
      row: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        padding: '1px 0',
        column: {
          flex: '1 1 auto',
        },
      },
      teamLabel: {
        fontSize: '11px',
        fontWeight: 'bold',
        paddingRight: '5px',
      },
      teamName: {
        fontSize: '10px',
        flex: '1 1',
        maxLines: 1,
        marginTop: '1px',
      },
    },
    teamFoulBoxes: {
      display: 'flex',
      flexDirection: 'row',
      periodContainer: {
        display: 'flex',
        flexDirection: 'row',
        period: {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          margin: '0 4px',
        },
      },
      fouls: {
        display: 'flex',
        flexDirection: 'row',
        marginLeft: '5px',
        box: {
          padding: '1px 3px',
          border: '1px solid #000',
        },
      },
    },
    table: {
      content: {
        margin: '2px',
        maxLines: 1,
      },
      row: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        borderBottom: '1px solid #000',
        column: {
          flex: '1 1',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          maxWidth: '100%',
          overflow: 'hidden',
        },
        columnBox: {
          flex: '1 1 16px',
          maxWidth: '16px',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          borderRight: '1px solid #000',
          borderLeft: '1px solid #000',
        },
        columnFouls: {
          flex: '1 1 65px',
          maxWidth: '65px',
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
          fouls: {
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            width: '15px',
            height: '100%',
            // borderRight: '1px solid #000',
            border: '1px solid #000',
          },
        },
      },
      coachRow: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        height: '20px',
        alignItems: 'center',
        justifyContent: 'space-between',
        borderBottom: '1px solid #000',
        name: {
          flex: '1',
          flexDirection: 'column',
          maxWidth: '100%',
          overflow: 'hidden',
          textAlign: 'left',
        },
        label: {
          margin: '2px',
          width: '55px',
        },
        columnFouls: {
          width: '45px',
          height: '100%',
          flexDirection: 'row',
          justifyContent: 'flex-end',
          alignItems: 'flex-end',
          fouls: {
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            width: '13px',
            height: '100%',
            borderRight: '1px solid #000',
            borderLeft: '1px solid #000',
          },
        },
      },
    },
    square: {
      width: '13px',
      height: '13px',
      border: '1px solid #000',
    },
  },
});

function PeriodFouls({ period, team }: { period: number; team: Team }) {
  return (
    <View style={styles.teamContainer.teamFoulBoxes}>
      <View style={styles.teamContainer.teamFoulBoxes.periodContainer}>
        {(period === 1 || period === 3) && <Text>Quarto</Text>}
        <Text style={styles.teamContainer.teamFoulBoxes.periodContainer.period}>
          {period}
        </Text>
      </View>
      <View style={styles.teamContainer.teamFoulBoxes.fouls}>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>1</Text>
        </View>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>2</Text>
        </View>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>3</Text>
        </View>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>4</Text>
        </View>
      </View>
    </View>
  );
}

function TeamFouls({ team }: { team: Team }) {
  return (
    <View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={1} team={team} />
        </View>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={2} team={team} />
        </View>
      </View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={3} team={team} />
        </View>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={4} team={team} />
        </View>
      </View>
    </View>
  );
}

function Timeouts() {
  return (
    <View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.square}></View>
        <View style={styles.teamContainer.square}></View>
      </View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.square}></View>
        <View style={styles.teamContainer.square}></View>
        <View style={styles.teamContainer.square}></View>
      </View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.square}></View>
        <View style={styles.teamContainer.square}></View>
        <View style={styles.teamContainer.square}></View>
      </View>
    </View>
  );
}

export interface TeamProps {
  type: 'A' | 'B';
  team: Team;
}

export default function TeamBox({ type, team }: TeamProps) {
  const renderPlayers = Array.from({ length: 12 }).map((_, index) => {
    const teamPlayer = team.players[index] || null;
    const fouls = Array.from({ length: 5 }).fill({});
    if (teamPlayer) {
      return {
        name: teamPlayer.name,
        number: teamPlayer.number,
        fouls: fouls.map((_, index) => ({
          type: teamPlayer.fouls[index]?.type || '',
          period: teamPlayer.fouls[index]?.period || 0,
        })),
      };
    }
    return {
      name: '',
      number: null,
      fouls,
    };
  });

  return (
    <View style={styles.teamContainer}>
      <View style={styles.teamContainer.header}>
        <View style={styles.teamContainer.header.row}>
          <Text style={styles.teamContainer.header.teamLabel}>
            Equipe {type}
          </Text>
          <Text style={styles.teamContainer.header.teamName}>{team.name}</Text>
        </View>
        <View style={styles.teamContainer.header.row}>
          <View style={styles.teamContainer.header.row.column}>
            <Text>Tempos Debitados</Text>
            <Timeouts />
          </View>
          <View style={styles.teamContainer.header.row.column}>
            <Text>Faltas de Equipe </Text>
            <TeamFouls team={team} />
          </View>
        </View>
      </View>
      <View style={styles.teamContainer.table}>
        <View style={styles.teamContainer.table.row}>
          <View style={styles.teamContainer.table.row.column}>
            <Text style={styles.teamContainer.table.content}>
              Nome de atletas
            </Text>
          </View>
          <View style={styles.teamContainer.table.row.columnBox}>
            <Text style={styles.teamContainer.table.content}>Nº</Text>
          </View>
          <View style={styles.teamContainer.table.row.columnBox}>
            <Text style={styles.teamContainer.table.content}>E.</Text>
          </View>
          <View style={styles.teamContainer.table.row.columnFouls}>
            <Text>Faltas</Text>
          </View>
        </View>
        {renderPlayers.map((player, index) => (
          <View key={index} style={styles.teamContainer.table.row}>
            <View
              style={{
                ...styles.teamContainer.table.row.column,
                flexDirection: 'row',
                justifyContent: 'start',
              }}
            >
              <Text style={styles.teamContainer.table.content}>
                {player.name}
              </Text>
            </View>
            <View style={styles.teamContainer.table.row.columnBox}>
              <Text style={styles.teamContainer.table.content}>
                {player.number !== null ? player.number : ''}
              </Text>
            </View>
            <View style={styles.teamContainer.table.row.columnBox}>
              <Text style={styles.teamContainer.table.content}>X</Text>
            </View>
            <View style={styles.teamContainer.table.row.columnFouls}>
              {player.fouls.map((foul, index) => (
                <View
                  style={styles.teamContainer.table.row.columnFouls.fouls}
                >
                  <Text key={index} style={styles.teamContainer.table.content}>
                    {foul.type}
                  </Text>
                </View>
              ))}
            </View>
          </View>
        ))}
        <View style={styles.teamContainer.table.coachRow}>
          <View style={styles.teamContainer.table.coachRow.label}>
            <Text>Técnico</Text>
          </View>
          <View style={styles.teamContainer.table.coachRow.name}>
            <Text>{team.coach.name}</Text>
          </View>
          <View style={styles.teamContainer.table.coachRow.columnFouls}>
            <View
              style={styles.teamContainer.table.coachRow.columnFouls.fouls}
            ></View>
            <View
              style={styles.teamContainer.table.coachRow.columnFouls.fouls}
            ></View>
            <View
              style={styles.teamContainer.table.coachRow.columnFouls.fouls}
            ></View>
          </View>
        </View>
        <View style={styles.teamContainer.table.coachRow}>
          <View style={styles.teamContainer.table.coachRow.label}>
            <Text>Ass. Técnico</Text>
          </View>
          <View style={styles.teamContainer.table.coachRow.name}>
            <Text>{team.assistant_coach.name}</Text>
          </View>
          <View style={styles.teamContainer.table.coachRow.columnFouls}>
            <View
              style={styles.teamContainer.table.coachRow.columnFouls.fouls}
            ></View>
            <View
              style={styles.teamContainer.table.coachRow.columnFouls.fouls}
            ></View>
            <View
              style={styles.teamContainer.table.coachRow.columnFouls.fouls}
            ></View>
          </View>
        </View>
      </View>
    </View>
  );
}
