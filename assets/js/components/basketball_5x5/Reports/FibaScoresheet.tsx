import React from 'react';
import { Document, Page, Text, View, StyleSheet } from '@react-pdf/renderer';
import RunningScoreBox from './FibaScoresheet/RunningScoreBox';
import TeamBox from './FibaScoresheet/TeamBox';
import OfficialsBox from './FibaScoresheet/OfficialsBox';
import FiscalsBox from './FibaScoresheet/FiscalsBox';
import HeaderBox from './FibaScoresheet/HeaderBox';

export interface PlayerFoul {
  type: 'P' | 'P1' | 'P2' | 'T';
  period: number;
}

export interface Coach {
  name: string;
  fouls: PlayerFoul[];
}

export interface Player {
  name: string;
  number: number;
  fouls: PlayerFoul[];
  has_started: boolean;
  has_played: boolean;
  is_captain: boolean;
}

export interface Timeout {
  minute: number;
  period: number;
}

export interface ScoreMark {
  type: 'FT' | '2PT' | '3PT';
  player_number: number;
  period: number;
  is_last_of_period: boolean;
}

export interface RunningScore {
  [score: number]: ScoreMark;
}

export interface Team {
  name: string;
  players: Player[];
  timeouts: Timeout[];
  running_score: RunningScore;
  coach: Coach;
  assistant_coach: Coach;
  score: number;
  all_fouls: PlayerFoul[];
}

const styles = StyleSheet.create({
  page: {
    flexDirection: 'column',
    backgroundColor: '#FFFFFF',
    padding: '10px',
    fontSize: 9,
  },
  title: {
    margin: 'auto',
    fontSize: 10,
    textAlign: 'center',
    width: '100%',
  },
  main: {
    border: '2px solid #000',
    margin: 'auto',
    height: '97%',
    width: '100%',
    header: {
      borderBottom: '2px solid #000',
      height: '50px',
    },
    teamsAndRunningScoreContainer: {
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'space-between',
      height: '100%',
      containerLeft: {
        borderRight: '1px solid #000',
        flex: '1 1',
      },
      containerRight: {
        borderLeft: '1px solid #000',
        flex: '1 1',
      },
    },
  },
  periods: {
    borderTop: '1px solid #000',
    borderBottom: '1px solid #000',
    fontSize: '8px',
    padding: '5px',
    row: {
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'space-between',
      padding: '3px 0',
      column: {
        flex: '1 1',
        display: 'flex',
      },
    },
    period: {
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'space-between',
      padding: '0 3px',
      quarter: {
        display: 'flex',
        flex: '1 1',
      },
      score: {
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'space-between',
        flex: '1 1',
      },
    },
  },
});

interface Period {
  isQuarterCentered?: boolean;
  period: string;
  teamAScore: number;
  teamBScore: number;
}

function Period({
  period,
  teamAScore,
  teamBScore,
  isQuarterCentered = false,
}: Period) {
  const quarterStyle = isQuarterCentered
    ? {
        ...styles.periods.period.quarter,
        justifyContent: 'center',
        alignItems: 'center',
      }
    : styles.periods.period.quarter;
  return (
    <View style={styles.periods.period}>
      <View style={quarterStyle}>
        <Text>{period}</Text>
      </View>
      <View style={styles.periods.period.score}>
        <Text>A</Text>
        <Text>{teamAScore}</Text>
        <Text>B</Text>
        <Text>{teamBScore}</Text>
      </View>
    </View>
  );
}

function generateTeamPeriodsScores(team: Team) {
  const lastPointScorePerPeriod = Object.entries(team.running_score).reduce(
    (acc, [keyAsScore, value]) => {
      if (value.period <= 4 && value.is_last_of_period) {
        acc[value.period] = keyAsScore;
      }
      return acc;
    },
    {},
  );

  return {
    1: lastPointScorePerPeriod[1] || 0,
    2: (lastPointScorePerPeriod[2] || 0) - (lastPointScorePerPeriod[1] || 0),
    3: (lastPointScorePerPeriod[3] || 0) - (lastPointScorePerPeriod[2] || 0),
    4: (lastPointScorePerPeriod[4] || 0) - (lastPointScorePerPeriod[3] || 0),
    5: (team.score || 0) - (lastPointScorePerPeriod[4] || 0),
  };
}

function Periods({ teamA, teamB }: { teamA: Team; teamB: Team }) {
  const teamAPeriodsScores = generateTeamPeriodsScores(teamA);
  const teamBPeriodsScores = generateTeamPeriodsScores(teamB);
  return (
    <View style={styles.periods}>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <Period
            period="Quarto 1"
            teamAScore={teamAPeriodsScores[1]}
            teamBScore={teamBPeriodsScores[1]}
          />
        </View>
        <View style={styles.periods.row.column}>
          <Period
            period="2"
            isQuarterCentered
            teamAScore={teamAPeriodsScores[2]}
            teamBScore={teamBPeriodsScores[2]}
          />
        </View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <Period
            period="Quarto 3"
            teamAScore={teamAPeriodsScores[3]}
            teamBScore={teamBPeriodsScores[3]}
          />
        </View>
        <View style={styles.periods.row.column}>
          <Period
            period="4"
            isQuarterCentered
            teamAScore={teamAPeriodsScores[4]}
            teamBScore={teamBPeriodsScores[4]}
          />
        </View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <Period
            period="Quarto extras"
            teamAScore={teamAPeriodsScores[5]}
            teamBScore={teamBPeriodsScores[5]}
          />
        </View>
        <View style={styles.periods.row.column}></View>
      </View>
    </View>
  );
}

function EndResults({ teamA, teamB }: { teamA: Team; teamB: Team }) {
  const winnerTeam = teamA.score > teamB.score ? teamA : teamB;
  return (
    <View style={styles.periods}>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <Period
            period="Resultado final"
            teamAScore={teamA.score}
            teamBScore={teamB.score}
          />
        </View>
        <View style={styles.periods.row.column}></View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>Equipe vencedora</Text>
            </View>
            <View style={styles.periods.period.score}>
              <Text>{winnerTeam.name}</Text>
            </View>
          </View>
        </View>
      </View>
    </View>
  );
}

function Protest() {
  return (
    <View style={styles.periods}>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>Súmula protestada?</Text>
            </View>
            <View style={styles.periods.period.score}>
              <Text>Assinatura capitão caso prostesto</Text>
            </View>
          </View>
        </View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>Não</Text>
            </View>
            <View style={styles.periods.period.score}></View>
          </View>
        </View>
      </View>
    </View>
  );
}

function EndGame() {
  return (
    <View style={styles.periods}>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>Fim de jogo às (hh:mm)</Text>
            </View>
            <View style={styles.periods.period.score}>
              <Text>21:30</Text>
            </View>
          </View>
        </View>
      </View>
    </View>
  );
}

const MOCK_DATA: {
  aTeam: Team;
  bTeam: Team;
} = {
  aTeam: {
    name: 'LA Lakers',
    players: [
      {
        name: 'LeBron James asd asdas dc adsasdawqeqweqwed asd asd asd as',
        number: 23,
        fouls: [],
      },
      { name: 'Anthony Davis', number: 3, fouls: [] },
      { name: 'Russell Westbrook', number: 0, fouls: [] },
    ],
    timeouts: [],
    runningScore: {
      1: { type: 'FT', player: 23, is_last_of_period: false },
      3: { type: '2PT', player: 3, is_last_of_period: false },
      6: { type: '3PT', player: 0, is_last_of_period: false },
      7: { type: 'FT', player: 23, is_last_of_period: true },
      9: { type: '2PT', player: 3, is_last_of_period: false },
    },
    coach: {
      name: 'Frank Vogel asd asd qwe aszd ads xcv cxv adsf asd qweq wadsa cxv edwferw',
      fouls: [],
    },
    assistant_coach: {
      name: 'Jason Kidd',
      fouls: [],
    },
  },
  bTeam: {
    name: 'Golden State Warriors as dasd asd asd asd asd qewqeqweqw asqweqwqwe qweqdasd',
    players: [
      { name: 'Stephen Curry', number: 30, fouls: [] },
      { name: 'Klay Thompson', number: 11, fouls: [] },
      { name: 'Draymond Green', number: 23, fouls: [] },
    ],
    timeouts: [],
    runningScore: {
      2: { type: 'FT', player: 30, is_last_of_period: false },
      4: { type: '2PT', player: 11, is_last_of_period: false },
      5: { type: '3PT', player: 23, is_last_of_period: false },
      8: { type: 'FT', player: 30, is_last_of_period: true },
      10: { type: '2PT', player: 11, is_last_of_period: false },
    },
    coach: {
      name: 'Steve Kerr',
      fouls: [],
    },
    assistant_coach: {
      name: 'Mike Brown',
      fouls: [],
    },
  },
};

export interface FibaScoresheetData {
  game_id: string;
  team_a: Team;
  team_b: Team;
}

interface FibaScoresheetProps {
  scoresheetData: FibaScoresheetData;
}

function FibaScoresheet({ scoresheetData }: FibaScoresheetProps) {
  return (
    <Document>
      <Page size="A4" style={styles.page}>
        <View style={styles.title}>
          <Text>Liga de Basquete Amador</Text>
        </View>
        <View style={styles.main}>
          <View style={styles.main.header}>
            <HeaderBox scoresheetData={scoresheetData} />
          </View>
          <View style={styles.main.teamsAndRunningScoreContainer}>
            <View
              style={styles.main.teamsAndRunningScoreContainer.containerLeft}
            >
              <TeamBox type="A" team={scoresheetData.team_a} />
              <TeamBox type="B" team={scoresheetData.team_b} />
              <OfficialsBox />
              <FiscalsBox />
            </View>
            <View
              style={styles.main.teamsAndRunningScoreContainer.containerRight}
            >
              <RunningScoreBox
                aTeamRunningScore={scoresheetData.team_a.running_score}
                bTeamRunningScore={scoresheetData.team_b.running_score}
              />
              <Periods
                teamA={scoresheetData.team_a}
                teamB={scoresheetData.team_b}
              />
              <EndResults
                teamA={scoresheetData.team_a}
                teamB={scoresheetData.team_b}
              />
              <Protest />
              <EndGame />
            </View>
          </View>
        </View>
      </Page>
    </Document>
  );
}

export default FibaScoresheet;
