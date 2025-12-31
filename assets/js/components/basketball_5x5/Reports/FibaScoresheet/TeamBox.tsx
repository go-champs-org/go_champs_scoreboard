import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { Coach, CoachFoul, Team, Timeout } from '../FibaScoresheet';
import { textColorForPeriod, RED, BLUE, colorForPeriod } from './styles';

const EMPTY_FOUL = {
  type: '',
  period: 0,
  extra_action: '',
  is_last_of_half: false,
};

const styles = StyleSheet.create({
  teamContainer: {
    borderBottom: '1px solid #000',
    header: {
      display: 'flex',
      flexDirection: 'column',
      padding: '3px 5px',
      borderBottom: '1px solid #000',
      row: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        margin: '1px 0',
        column: {
          flex: '1 1 auto',
        },
      },
      teamLabel: {
        fontSize: '9px',
        fontWeight: 'bold',
        paddingRight: '5px',
      },
      teamName: {
        fontSize: '9px',
        flex: '1 1',
        maxLines: 1,
      },
    },
    teamFoulBoxes: {
      display: 'flex',
      flexDirection: 'row',
      periodContainer: {
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
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
          unused: {
            position: 'absolute',
            top: '3px',
            left: '0',
            width: '100%',
            height: '5px',
            borderTop: `2px solid ${BLUE}`,
            borderBottom: `2px solid ${BLUE}`,
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
        borderRadius: '75px',
        color: BLUE,
        padding: '2px 4px 0px 4px',
        margin: '1px 0 0 1px',
        height: '100%',
        widht: '100%',
        maxLines: 1,
      },
      row: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        borderBottom: '1px solid #000',
        height: '15px',
        columnLic: {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          width: '24px',
          overflow: 'hidden',
          borderRight: '1px solid #000',
        },
        column: {
          flex: '1 1',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          maxWidth: '100%',
          overflow: 'hidden',
          unused: {
            position: 'absolute',
            top: '6px',
            width: '100%',
            height: '2px',
            borderTop: `2px solid ${BLUE}`,
          },
        },
        columnName: {
          marginLeft: '2px',
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'center',
          width: '100%',
          maxWidth: '100%',
          overflow: 'hidden',
          playerName: {
            flex: '1 1 auto',
            maxLines: 1,
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
            minWidth: 0,
          },
          playerCaptain: {
            width: '25px',
            fontStyle: 'italic',
            flexShrink: 0,
            whiteSpace: 'nowrap',
          },
        },
        columnBox: {
          flex: '1 1 15px',
          maxWidth: '15px',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          borderLeft: '1px solid #000',
        },
        columnFouls: {
          flex: '1 1 84px',
          maxWidth: '84px',
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
          fouls: {
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            width: '14px',
            height: '100%',
            borderLeft: '1px solid #000',
            position: 'relative',
            type: {
              position: 'absolute',
              top: '1px',
              left: '1px',
            },
            extraAction: {
              position: 'absolute',
              bottom: '1px',
              right: '1px',
              fontSize: '5px',
            },
          },
        },
      },
      coachRow: {
        display: 'flex',
        flexDirection: 'row',
        flex: '1 1 auto',
        height: '14px',
        borderBottom: '1px solid #000',
        name: {
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'center',
          flex: '1 1 auto',
          maxWidth: '100%',
          overflow: 'hidden',
        },
        label: {
          margin: '2px',
          width: '55px',
        },
        columnFouls: {
          height: '100%',
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
          fouls: {
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            width: '14px',
            height: '100%',
            borderLeft: '1px solid #000',
            position: 'relative',
            type: {
              position: 'absolute',
              top: '1px',
              left: '1px',
            },
            extraAction: {
              position: 'absolute',
              bottom: '1px',
              right: '3px',
              fontSize: '5px',
            },
          },
        },
      },
      walkoverMessage: {
        position: 'absolute',
        top: '35%',
        left: '12%',
        transform: 'rotate(-30deg)',
        backgroundColor: '#fff',
        padding: '5px',
        fontSize: '25px',
        fontWeight: 'bold',
        color: BLUE,
      },
    },
    square: {
      width: '13px',
      height: '13px',
      border: '1px solid #000',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      unused: {
        width: '100%',
        height: '5px',
        borderTop: `2px solid ${BLUE}`,
        borderBottom: `2px solid ${BLUE}`,
      },
    },
  },
});

function borderForFoul(foul: CoachFoul) {
  if (foul.type === 'BD') {
    return {
      margin: '-1px 0 0 -1px',
      padding: '1px 3px',
      border: `1px`,
      borderColor: colorForPeriod(foul.period),
      borderRadius: '50px',
    };
  }

  return {};
}

function foulContent(foul: CoachFoul) {
  if (foul.type === 'BD') {
    return 'B';
  }

  return foul.type;
}

function FoulBox({
  boxNumber,
  periodFouls,
  period,
  isGameEnded = false,
}: {
  boxNumber: number;
  periodFouls: any[];
  period: number;
  isGameEnded?: boolean;
}) {
  const usedFouls = periodFouls.length >= boxNumber;
  return (
    <View style={styles.teamContainer.teamFoulBoxes.fouls.box}>
      <Text>{boxNumber}</Text>
      {usedFouls ? (
        <Text
          style={{
            ...styles.teamContainer.teamFoulBoxes.fouls.box.x,
            ...textColorForPeriod(period),
          }}
        >
          X
        </Text>
      ) : (
        isGameEnded &&
        !usedFouls && (
          <View style={styles.teamContainer.teamFoulBoxes.fouls.box.unused} />
        )
      )}
    </View>
  );
}

function PeriodFouls({
  period,
  team,
  isGameEnded,
}: {
  period: number;
  team: Team;
  isGameEnded?: boolean;
}) {
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
        {[1, 2, 3, 4].map((boxNumber) => (
          <FoulBox
            key={boxNumber}
            boxNumber={boxNumber}
            periodFouls={periodFouls}
            period={period}
            isGameEnded={isGameEnded}
          />
        ))}
      </View>
    </View>
  );
}

function TeamFouls({
  team,
  isGameEnded = false,
}: {
  team: Team;
  isGameEnded?: boolean;
}) {
  return (
    <View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={1} team={team} isGameEnded={isGameEnded} />
        </View>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={2} team={team} isGameEnded={isGameEnded} />
        </View>
      </View>
      <View style={styles.teamContainer.header.row}>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={3} team={team} isGameEnded={isGameEnded} />
        </View>
        <View style={styles.teamContainer.header.row.column}>
          <PeriodFouls period={4} team={team} isGameEnded={isGameEnded} />
        </View>
      </View>
    </View>
  );
}

function TimeoutBoxList({
  timeouts,
  numberOfBoxes,
  isGameEnded = false,
}: {
  timeouts: Timeout[];
  numberOfBoxes: number;
  isGameEnded?: boolean;
}) {
  const renderTimeouts = Array.from({ length: numberOfBoxes }).map(
    (_, index) => timeouts[index] || null,
  );

  return (
    <View style={styles.teamContainer.header.row}>
      {renderTimeouts.map((timeout, index) => {
        const isRegularTimeout = timeout && !timeout.lost;
        const isLostTimeout = timeout?.lost;
        const shouldShowUnusedCell = isLostTimeout || (!timeout && isGameEnded);

        return (
          <View key={index} style={styles.teamContainer.square}>
            {isRegularTimeout ? (
              <Text style={textColorForPeriod(timeout.period)}>
                {timeout.minute}
              </Text>
            ) : (
              shouldShowUnusedCell && (
                <View style={styles.teamContainer.square.unused} />
              )
            )}
          </View>
        );
      })}
    </View>
  );
}

function Timeouts({
  team,
  isGameEnded,
}: {
  team: Team;
  isGameEnded?: boolean;
}) {
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
      <TimeoutBoxList
        timeouts={firstHalfTimeouts}
        numberOfBoxes={2}
        isGameEnded={isGameEnded}
      />
      <TimeoutBoxList
        timeouts={secondHalfTimeouts}
        numberOfBoxes={3}
        isGameEnded={isGameEnded}
      />
      <TimeoutBoxList
        timeouts={overtimeTimeouts}
        numberOfBoxes={3}
        isGameEnded={isGameEnded}
      />
    </View>
  );
}

export interface TeamProps {
  type: 'A' | 'B';
  team: Team;
  isGameEnded?: boolean;
}

function UnsedCell() {
  return <View style={styles.teamContainer.table.row.column.unused} />;
}

function ConditionalCell({
  isUnsed,
  children,
}: {
  isUnsed: boolean;
  children: React.ReactNode;
}) {
  if (isUnsed) {
    return <UnsedCell />;
  }
  return <>{children}</>;
}

function PlayerRow({
  player,
  isGameEnded = false,
  isFirstEmpty = false,
}: {
  player: any;
  isGameEnded?: boolean;
  isFirstEmpty?: boolean;
}) {
  const isFirstEmptyPlayerAndGameEnded = isFirstEmpty && isGameEnded;
  const isLicenseNumberUnsed =
    isFirstEmptyPlayerAndGameEnded ||
    (isGameEnded && !player.license_number && player.name);
  return (
    <View style={styles.teamContainer.table.row}>
      <View style={styles.teamContainer.table.row.columnLic}>
        <ConditionalCell isUnsed={isLicenseNumberUnsed}>
          <Text style={{ ...styles.teamContainer.table.content, margin: 0 }}>
            {player.license_number}
          </Text>
        </ConditionalCell>
      </View>
      <View
        style={{
          ...styles.teamContainer.table.row.column,
          flexDirection: 'row',
          justifyContent: 'start',
        }}
      >
        <ConditionalCell isUnsed={isFirstEmptyPlayerAndGameEnded}>
          <View style={styles.teamContainer.table.row.columnName}>
            <Text style={styles.teamContainer.table.row.columnName.playerName}>
              {player.name}
            </Text>
            {player.is_captain && (
              <Text
                style={styles.teamContainer.table.row.columnName.playerCaptain}
              >{`(CAP.)`}</Text>
            )}
          </View>
        </ConditionalCell>
      </View>
      <View style={styles.teamContainer.table.row.columnBox}>
        <ConditionalCell isUnsed={isFirstEmptyPlayerAndGameEnded}>
          <Text style={styles.teamContainer.table.content}>
            {player.number !== null ? player.number : ''}
          </Text>
        </ConditionalCell>
      </View>
      <View style={styles.teamContainer.table.row.columnBox}>
        <ConditionalCell isUnsed={isFirstEmptyPlayerAndGameEnded}>
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
        </ConditionalCell>
      </View>
      <View style={styles.teamContainer.table.row.columnFouls}>
        {player.fouls.map((foul, index) => (
          <View
            key={index}
            style={{
              ...styles.teamContainer.table.row.columnFouls.fouls,
              backgroundColor: index === 5 ? '#ddd' : 'transparent',
              ...defineFoulBorders(foul, index, false),
            }}
          >
            <ConditionalCell isUnsed={isFirstEmptyPlayerAndGameEnded}>
              {foul !== EMPTY_FOUL ? (
                <>
                  <Text
                    style={{
                      ...styles.teamContainer.table.row.columnFouls.fouls.type,
                      ...textColorForPeriod(foul.period),
                    }}
                  >
                    {foul.type}
                  </Text>
                  {foul.extra_action && (
                    <Text
                      style={{
                        ...styles.teamContainer.table.row.columnFouls.fouls
                          .extraAction,
                        ...textColorForPeriod(foul.period),
                      }}
                    >
                      {foul.extra_action}
                    </Text>
                  )}
                </>
              ) : (
                isGameEnded && <UnsedCell />
              )}
            </ConditionalCell>
          </View>
        ))}
      </View>
    </View>
  );
}

function CoachRow({
  coach,
  type,
  isGameEnded = false,
}: {
  coach: any;
  type: 'head' | 'assistant';
  isGameEnded?: boolean;
}) {
  const label = type === 'head' ? 'Técnico' : 'Ass. Técnico';
  return (
    <View style={styles.teamContainer.table.coachRow}>
      <View style={styles.teamContainer.table.coachRow.label}>
        <Text>{label}</Text>
      </View>
      <View style={styles.teamContainer.table.coachRow.name}>
        <ConditionalCell isUnsed={isGameEnded && coach.name === ''}>
          <Text>{coach.name}</Text>
        </ConditionalCell>
      </View>
      <View style={styles.teamContainer.table.coachRow.columnFouls}>
        {coach.fouls.map((foul, index) => (
          <View
            key={index}
            style={{
              ...styles.teamContainer.table.coachRow.columnFouls.fouls,
              backgroundColor: index === 3 ? '#ddd' : 'transparent',
              ...defineFoulBorders(foul, index, isGameEnded),
            }}
          >
            {foul !== EMPTY_FOUL ? (
              <>
                <Text
                  style={{
                    ...styles.teamContainer.table.coachRow.columnFouls.fouls
                      .type,
                    ...textColorForPeriod(foul.period),
                    ...borderForFoul(foul),
                  }}
                >
                  {foulContent(foul)}
                </Text>
                {foul.extra_action && (
                  <Text
                    style={{
                      ...styles.teamContainer.table.coachRow.columnFouls.fouls
                        .extraAction,
                      ...textColorForPeriod(foul.period),
                    }}
                  >
                    {foul.extra_action}
                  </Text>
                )}
              </>
            ) : (
              isGameEnded && <UnsedCell />
            )}
          </View>
        ))}
      </View>
    </View>
  );
}

function defineFoulBorders(
  foul: any,
  currentIndex: number,
  hasGameEnded: boolean = false,
) {
  const coachHasNoFoulsAndGameEnded =
    foul === EMPTY_FOUL && hasGameEnded && currentIndex === 0;
  const borderLeft =
    coachHasNoFoulsAndGameEnded || foul.period >= 3
      ? `2px solid ${BLUE}`
      : '1px solid #000';

  const borderRight = foul.is_last_of_half ? `2px solid ${BLUE}` : 'none';

  return { borderLeft, borderRight };
}

function createRenderCoach(coach: Coach) {
  const coachFouls = Array.from({ length: 4 })
    .fill({})
    .map((_, index) =>
      coach.fouls[index]
        ? {
            type: coach.fouls[index].type,
            period: coach.fouls[index].period,
            extra_action: coach.fouls[index].extra_action,
            is_last_of_half: coach.fouls[index].is_last_of_half,
          }
        : EMPTY_FOUL,
    );
  return coach
    ? { ...coach, fouls: coachFouls }
    : { name: '', id: '', fouls: coachFouls };
}

export default function TeamBox({
  type,
  team,
  isGameEnded = false,
}: TeamProps) {
  const renderPlayers = Array.from({ length: 12 }).map((_, index) => {
    const teamPlayer = team.players[index] || null;
    const fouls = Array.from({ length: 6 }).fill({});
    if (teamPlayer) {
      return {
        name: teamPlayer.name,
        number: teamPlayer.number,
        fouls: fouls.map((_, index) =>
          teamPlayer.fouls[index]
            ? {
                type: teamPlayer.fouls[index].type,
                period: teamPlayer.fouls[index].period,
                extra_action: teamPlayer.fouls[index].extra_action,
                is_last_of_half: teamPlayer.fouls[index].is_last_of_half,
              }
            : EMPTY_FOUL,
        ),
        license_number: teamPlayer.license_number || '',
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
      license_number: '',
      has_started: false,
      has_played: false,
      is_captain: false,
      first_played_period: 0,
    };
  });
  const sortedRenderPlayers = renderPlayers.sort((a, b) => {
    if (a.number === null) return 1;
    if (b.number === null) return -1;
    return a.number - b.number;
  });
  /** The index of the first player with an empty or whitespace-only name is used to know where to draw the end game line. */
  const firstEmptyPlayerIndex = sortedRenderPlayers.findIndex(
    (player) => player.name === '' || player.name.trim() === '',
  );

  const renderCoach = createRenderCoach(team.coach);
  const renderAssistantCoach = createRenderCoach(team.assistant_coach);

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
            <Timeouts team={team} isGameEnded={isGameEnded} />
          </View>
          <View style={styles.teamContainer.header.row.column}>
            <Text>Faltas de Equipe </Text>
            <TeamFouls team={team} isGameEnded={isGameEnded} />
          </View>
        </View>
      </View>
      <View style={styles.teamContainer.table}>
        <View style={styles.teamContainer.table.row}>
          <View style={styles.teamContainer.table.row.columnLic}>
            <Text style={styles.teamContainer.table.content}>Lic #</Text>
          </View>
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
          <View
            style={{
              ...styles.teamContainer.table.row.columnFouls,
              borderLeft: '1px solid #000',
            }}
          >
            <Text>Faltas</Text>
          </View>
        </View>
        {team.has_walkover ? (
          <>
            {sortedRenderPlayers.map((player, index) => (
              <PlayerRow
                key={index}
                player={player}
                isGameEnded={false}
              ></PlayerRow>
            ))}
            <CoachRow coach={renderCoach} type="head" isGameEnded={false} />
            <CoachRow
              coach={renderAssistantCoach}
              type="assistant"
              isGameEnded={false}
            ></CoachRow>
            <View style={styles.teamContainer.table.walkoverMessage}>
              <Text>AUSENTE</Text>
            </View>
          </>
        ) : (
          <>
            {sortedRenderPlayers.map((player, index) => (
              <PlayerRow
                key={index}
                player={player}
                isGameEnded={isGameEnded}
                isFirstEmpty={index === firstEmptyPlayerIndex}
              />
            ))}
            <CoachRow
              coach={renderCoach}
              type="head"
              isGameEnded={isGameEnded}
            />
            <CoachRow
              coach={renderAssistantCoach}
              type="assistant"
              isGameEnded={isGameEnded}
            />
          </>
        )}
      </View>
    </View>
  );
}
