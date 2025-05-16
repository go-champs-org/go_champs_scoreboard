import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { Team, Timeout } from '../FibaScoresheet';
import { textColorForPeriod, RED, BLUE } from './styles';

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
          position: 'relative',
          x: {
            position: 'absolute',
            top: '-2px',
            left: '1px',
            fontSize: '14px',
          },
        },
      },
    },
    table: {
      content: {
        margin: '2px',
        maxLines: 1,
      },
      contentWithCircle: {
        border: `1px solid ${RED}`,
        borderRadius: '50px',
        color: BLUE,
        paddingLeft: '3px',
        paddingRight: '2px',
        paddingTop: '1px',
        margin: '1px',
        maxLines: 1,
      },
      row: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        borderBottom: '1px solid #000',
        minHeight: '14px',
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
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
    },
  },
});

function PeriodFouls({ period, team }: { period: number; team: Team }) {
  const periodFouls = team.all_fouls.filter((foul) => foul.period === period);
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
          {periodFouls.length >= 1 && (
            <Text
              style={{
                ...styles.teamContainer.teamFoulBoxes.fouls.box.x,
                ...textColorForPeriod(period),
              }}
            >
              X
            </Text>
          )}
        </View>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>2</Text>
          {periodFouls.length >= 2 && (
            <Text
              style={{
                ...styles.teamContainer.teamFoulBoxes.fouls.box.x,
                ...textColorForPeriod(period),
              }}
            >
              X
            </Text>
          )}
        </View>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>3</Text>
          {periodFouls.length >= 3 && (
            <Text
              style={{
                ...styles.teamContainer.teamFoulBoxes.fouls.box.x,
                ...textColorForPeriod(period),
              }}
            >
              X
            </Text>
          )}
        </View>
        <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
          <Text>4</Text>
          {periodFouls.length >= 4 && (
            <Text
              style={{
                ...styles.teamContainer.teamFoulBoxes.fouls.box.x,
                ...textColorForPeriod(period),
              }}
            >
              X
            </Text>
          )}
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

function TimeoutBoxList({
  timeouts,
  numberOfBoxes,
}: {
  timeouts: Timeout[];
  numberOfBoxes: number;
}) {
  const renderTimeouts = Array.from({ length: numberOfBoxes }).map(
    (_, index) => timeouts[index] || null,
  );

  return (
    <View style={styles.teamContainer.header.row}>
      {renderTimeouts.map((timeout, index) => (
        <View key={index} style={styles.teamContainer.square}>
          {timeout && (
            <Text style={textColorForPeriod(timeout.period)}>
              {timeout.minute}
            </Text>
          )}
        </View>
      ))}
    </View>
  );
}

function Timeouts({ team }: { team: Team }) {
  const firstHalfTimeouts = team.timeouts.filter(
    (timeout) => timeout.period === 1 || timeout.period === 2,
  );
  const secondHalfTimeouts = team.timeouts.filter(
    (timeout) => timeout.period === 3 || timeout.period === 4,
  );
  const overtimeTimeouts = team.timeouts.filter(
    (timeout) => timeout.period >= 5,
  );

  return (
    <View>
      <TimeoutBoxList timeouts={firstHalfTimeouts} numberOfBoxes={2} />
      <TimeoutBoxList timeouts={secondHalfTimeouts} numberOfBoxes={3} />
      <TimeoutBoxList timeouts={overtimeTimeouts} numberOfBoxes={3} />
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
        has_started: teamPlayer.has_started,
        first_played_period: teamPlayer.first_played_period,
        has_played: teamPlayer.has_played,
        is_captain: teamPlayer.is_captain,
      };
    }
    return {
      name: '',
      number: null,
      fouls,
      has_started: false,
      has_played: false,
      is_captain: false,
      first_played_period: 0,
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
            <Timeouts team={team} />
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
              {player.has_played ? (
                <Text
                  style={
                    player.has_started
                      ? styles.teamContainer.table.contentWithCircle
                      : {
                          ...styles.teamContainer.table.content,
                          ...textColorForPeriod(player.first_played_period),
                        }
                  }
                >
                  X
                </Text>
              ) : (
                <></>
              )}
            </View>
            <View style={styles.teamContainer.table.row.columnFouls}>
              {player.fouls.map((foul, index) => (
                <View
                  key={index}
                  style={styles.teamContainer.table.row.columnFouls.fouls}
                >
                  <Text
                    style={{
                      ...styles.teamContainer.table.content,
                      ...textColorForPeriod(foul.period),
                    }}
                  >
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
