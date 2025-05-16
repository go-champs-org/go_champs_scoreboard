import React from 'react';
import { Text, View, StyleSheet } from '@react-pdf/renderer';
import { RunningScore, ScoreMark } from '../FibaScoresheet';
import { backgroundColorForPeriod, textColorForPeriod } from './styles';

const styles = StyleSheet.create({
  runningScore: {
    margin: 'auto',
    height: '98%',
    width: '97%',
    border: '1px solid #000',
    header: {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      borderBottom: '1px solid #000',
      height: '30px',
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
            borderRight: '1px solid #000',
          },
          numberContainer: {
            flex: '1 1 50%',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
          },
        },
      },
    },
  },
});

function ScoreMark({
  number,
  runningScore,
}: {
  key: number;
  number: number;
  runningScore: RenderRunningScore;
}) {
  return (
    <View style={styles.runningScore.columnsContainer.column.scoreMark}>
      <View
        style={
          styles.runningScore.columnsContainer.column.scoreMark.playerContainer
        }
      >
        {runningScore[number] && (
          <Text style={textColorForPeriod(runningScore[number].period)}>
            {runningScore[number].player_number}
          </Text>
        )}
      </View>
      <View
        style={
          styles.runningScore.columnsContainer.column.scoreMark.numberContainer
        }
      >
        <Text>{number}</Text>
      </View>
      {runningScore[number] && runningScore[number].is_last_of_period && (
        <View
          style={{
            ...styles.runningScore.columnsContainer.column.scoreMark
              .endPeriodLine,
            ...backgroundColorForPeriod(runningScore[number].period),
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
}: {
  runningScore: RenderRunningScore;
  firstNumber: number;
  lastNumber: number;
}) {
  const scoreList = Array.from(
    { length: lastNumber - firstNumber + 1 },
    (_, i) => i + firstNumber,
  );
  return (
    <>
      {scoreList.map((number) => (
        <ScoreMark key={number} number={number} runningScore={runningScore} />
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
  bTeamRunningScore,
}: {
  aTeamRunningScore: RunningScore;
  bTeamRunningScore: RunningScore;
}) {
  const aTeamFullRunningScore = generateRunningScoreData(aTeamRunningScore);
  const bTeamFullRunningScore = generateRunningScoreData(bTeamRunningScore);
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
          />
        </View>
      </View>
    </View>
  );
}
