import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { RunningScore, ScoreMark } from '../FibaScoresheet';
import { backgroundColorForPeriod, BLUE, textColorForPeriod } from './styles';

const styles = StyleSheet.create({
  runningScore: {
    margin: '0 auto',
    height: '84%',
    width: '95%',
    borderRight: '1px solid #000',
    borderLeft: '1px solid #000',
    header: {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      borderBottom: '1px solid #000',
      height: '18px',
    },
    columnsContainer: {
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'space-between',
      width: '100%',
      height: '100%',
      column: {
        borderRight: '1px solid #000',
        flex: '1 1 auto',
        team: {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          borderBottom: '1px solid #000',
          height: '100%',
        },
        scoreMark: {
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'space-between',
          borderBottom: '1px solid #000',
          fontSize: '8px',
          height: '100%',
          position: 'relative',
          endPeriodLine: {
            position: 'absolute',
            bottom: '-2px',
            left: '0',
            width: '100%',
            height: '2px',
          },
          playerContainer: {
            flex: '1 1 50%',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            position: 'relative',
            circle: {
              position: 'absolute',
              top: '0',
              left: '0',
              height: '100%',
              width: '100%',
              borderRadius: '15px',
              borderWidth: '1px',
            },
            middleLine: {
              position: 'absolute',
              top: '0',
              left: '49%',
              width: '2px',
              height: '100%',
            },
          },
          numberContainer: {
            flex: '1 1 50%',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            position: 'relative',
            dot: {
              position: 'absolute',
              top: '5px',
              left: '6px',
              width: '4px',
              height: '4px',
              borderRadius: '2px',
            },
            slash: {
              position: 'absolute',
              top: '6px',
              left: '-2px',
              height: '2px',
              width: '21px',
              transform: 'rotate(37deg)',
            },
            circle: {
              position: 'absolute',
              top: '0',
              left: '0',
              height: '100%',
              width: '100%',
              borderRadius: '50px',
              borderWidth: '1px',
            },
            middleLine: {
              position: 'absolute',
              top: '0',
              left: '49%',
              width: '2px',
              height: '100%',
            },
          },
        },
      },
    },
  },
});

function ScoreMarkDisplay({
  number,
  runningScore,
  isReversed = false,
  isNotUsed = false,
}: {
  key: number;
  number: number;
  runningScore: RenderRunningScore;
  isReversed: boolean;
  isNotUsed: boolean;
}) {
  const score = runningScore[number];
  return (
    <View
      style={{
        ...styles.runningScore.columnsContainer.column.scoreMark,
        flexDirection: isReversed ? 'row-reverse' : 'row',
      }}
    >
      <View
        style={{
          ...styles.runningScore.columnsContainer.column.scoreMark
            .playerContainer,
          borderRight: !isReversed ? '1px solid #000' : 'none',
          borderLeft: isReversed ? '1px solid #000' : 'none',
        }}
      >
        {score && (
          <Text style={textColorForPeriod(score.period)}>
            {score.player_number}
          </Text>
        )}
        {score && score.type === '3PT' && (
          <View
            style={{
              ...styles.runningScore.columnsContainer.column.scoreMark
                .playerContainer.circle,
              borderColor: textColorForPeriod(score.period).color,
            }}
          />
        )}
        {isNotUsed && (
          <View
            style={{
              ...styles.runningScore.columnsContainer.column.scoreMark
                .playerContainer.middleLine,
              backgroundColor: BLUE,
            }}
          />
        )}
      </View>
      <View
        style={
          styles.runningScore.columnsContainer.column.scoreMark.numberContainer
        }
      >
        <Text>{number}</Text>
        {score && score.type === 'FT' && (
          <View
            style={{
              ...styles.runningScore.columnsContainer.column.scoreMark
                .numberContainer.dot,
              ...backgroundColorForPeriod(score.period),
            }}
          />
        )}
        {score && (score.type === '2PT' || score.type === '3PT') && (
          <View
            style={{
              ...styles.runningScore.columnsContainer.column.scoreMark
                .numberContainer.slash,
              ...backgroundColorForPeriod(score.period),
            }}
          />
        )}
        {score && score.is_last_of_period && (
          <View
            style={{
              ...styles.runningScore.columnsContainer.column.scoreMark
                .numberContainer.circle,
              borderColor: textColorForPeriod(score.period).color,
            }}
          />
        )}
        {isNotUsed && (
          <View
            style={{
              ...styles.runningScore.columnsContainer.column.scoreMark
                .numberContainer.middleLine,
              backgroundColor: BLUE,
            }}
          />
        )}
      </View>
      {score && score.is_last_of_period && (
        <View
          style={{
            ...styles.runningScore.columnsContainer.column.scoreMark
              .endPeriodLine,
            ...backgroundColorForPeriod(score.period),
          }}
        ></View>
      )}
    </View>
  );
}

interface RenderRunningScore {
  [key: number]: null | ScoreMark;
}

function ScoreList({
  runningScore,
  firstNumber,
  lastNumber,
  lastTeamScore,
  isReversed = false,
  isGameEnded = false,
}: {
  runningScore: RenderRunningScore;
  firstNumber: number;
  lastNumber: number;
  lastTeamScore: number;
  isReversed?: boolean;
  isGameEnded?: boolean;
}) {
  const scoreList = Array.from(
    { length: lastNumber - firstNumber + 1 },
    (_, i) => i + firstNumber,
  );
  return (
    <>
      {scoreList.map((number) => (
        <ScoreMarkDisplay
          key={number}
          number={number}
          runningScore={runningScore}
          isReversed={isReversed}
          isNotUsed={isGameEnded && number > lastTeamScore}
        />
      ))}
    </>
  );
}

function generateRunningScoreData(
  teamRunnigScore: RunningScore,
): RenderRunningScore {
  const allRunningScore = {};

  for (let i = 1; i <= 160; i++) {
    allRunningScore[i] = teamRunnigScore[i] || null;
  }

  return allRunningScore;
}

export default function RunningScoreBox({
  aTeamRunningScore,
  aTeamLastScore = 0,
  bTeamRunningScore,
  bTeamLastScore = 0,
  isGameEnded = false,
  hasWalkoverTeam = false,
}: {
  aTeamRunningScore: RunningScore;
  aTeamLastScore: number;
  bTeamRunningScore: RunningScore;
  bTeamLastScore: number;
  isGameEnded?: boolean;
  hasWalkoverTeam?: boolean;
}) {
  const aTeamFullRunningScore = generateRunningScoreData(aTeamRunningScore);
  const bTeamFullRunningScore = generateRunningScoreData(bTeamRunningScore);
  const aTeamLastScoreAdjusted = hasWalkoverTeam ? 0 : aTeamLastScore;
  const bTeamLastScoreAdjusted = hasWalkoverTeam ? 0 : bTeamLastScore;
  return (
    <View style={styles.runningScore}>
      <View style={styles.runningScore.header}>
        <Text>CONTAGEM PROGRESSIVA</Text>
      </View>
      <View style={styles.runningScore.columnsContainer}>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>A</Text>
          </View>
          <ScoreList
            runningScore={aTeamFullRunningScore}
            firstNumber={1}
            lastNumber={40}
            lastTeamScore={aTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>B</Text>
          </View>
          <ScoreList
            runningScore={bTeamFullRunningScore}
            firstNumber={1}
            lastNumber={40}
            isReversed
            lastTeamScore={bTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>A</Text>
          </View>
          <ScoreList
            runningScore={aTeamFullRunningScore}
            firstNumber={41}
            lastNumber={80}
            lastTeamScore={aTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>B</Text>
          </View>
          <ScoreList
            runningScore={bTeamFullRunningScore}
            firstNumber={41}
            lastNumber={80}
            isReversed
            lastTeamScore={bTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>A</Text>
          </View>
          <ScoreList
            runningScore={aTeamFullRunningScore}
            firstNumber={81}
            lastNumber={120}
            lastTeamScore={aTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>B</Text>
          </View>
          <ScoreList
            runningScore={bTeamFullRunningScore}
            firstNumber={81}
            lastNumber={120}
            isReversed
            lastTeamScore={bTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>A</Text>
          </View>
          <ScoreList
            runningScore={aTeamFullRunningScore}
            firstNumber={121}
            lastNumber={160}
            lastTeamScore={aTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
        <View style={styles.runningScore.columnsContainer.column}>
          <View style={styles.runningScore.columnsContainer.column.team}>
            <Text>B</Text>
          </View>
          <ScoreList
            runningScore={bTeamFullRunningScore}
            firstNumber={121}
            lastNumber={160}
            isReversed
            lastTeamScore={bTeamLastScoreAdjusted}
            isGameEnded={isGameEnded}
          />
        </View>
      </View>
    </View>
  );
}
