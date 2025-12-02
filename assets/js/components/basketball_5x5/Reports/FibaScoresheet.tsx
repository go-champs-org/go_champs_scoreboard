import React from 'react';
import { Document, Page, Text, View, StyleSheet } from '@react-pdf/renderer';
import RunningScoreBox from './FibaScoresheet/RunningScoreBox';
import TeamBox from './FibaScoresheet/TeamBox';
import OfficialsBox from './FibaScoresheet/OfficialsBox';
import FiscalsBox from './FibaScoresheet/FiscalsBox';
import HeaderBox from './FibaScoresheet/HeaderBox';
import { textColorForPeriod } from './FibaScoresheet/styles';

export interface PlayerFoul {
  type: 'P' | 'T' | 'U' | 'D' | 'GD';
  period: number;
  extra_action?: '1' | '2' | '3' | 'C' | '';
  is_last_of_half: boolean;
}

export interface CoachFoul {
  type: 'C' | 'D' | 'F' | 'B' | 'BD' | 'GD';
  period: number;
  extra_action?: '1' | '2' | '3' | 'C' | '';
  is_last_of_half: boolean;
}

export interface Coach {
  name: string;
  fouls: CoachFoul[];
}

export interface Player {
  name: string;
  number: number;
  fouls: PlayerFoul[];
  license_number: string;
  has_started: boolean;
  has_played: boolean;
  is_captain: boolean;
  first_played_period: number;
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

export interface Official {
  id: string;
  name: string;
}

export interface Protest {
  state: 'no_protest' | 'protest_filed';
  player_name: string;
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

export interface Info {
  number: string;
  location: string;
  datetime: string;
  tournament_name: string;
  actual_start_datetime: string;
  actual_end_datetime: string;
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
  period: number;
  periodLabel: string;
  teamAScore: number;
  teamBScore: number;
}

function Period({
  period,
  periodLabel,
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
        <Text>{periodLabel}</Text>
      </View>
      <View style={styles.periods.period.score}>
        <Text>A</Text>
        <Text style={textColorForPeriod(period)}>
          {teamAScore ? teamAScore : '-'}
        </Text>
        <Text>B</Text>
        <Text style={textColorForPeriod(period)}>
          {teamBScore ? teamBScore : '-'}
        </Text>
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
            period={1}
            periodLabel="Quarto 1"
            teamAScore={teamAPeriodsScores[1]}
            teamBScore={teamBPeriodsScores[1]}
          />
        </View>
        <View style={styles.periods.row.column}>
          <Period
            period={2}
            periodLabel="2"
            isQuarterCentered
            teamAScore={teamAPeriodsScores[2]}
            teamBScore={teamBPeriodsScores[2]}
          />
        </View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <Period
            period={3}
            periodLabel="Quarto 3"
            teamAScore={teamAPeriodsScores[3]}
            teamBScore={teamBPeriodsScores[3]}
          />
        </View>
        <View style={styles.periods.row.column}>
          <Period
            period={4}
            periodLabel="4"
            isQuarterCentered
            teamAScore={teamAPeriodsScores[4]}
            teamBScore={teamBPeriodsScores[4]}
          />
        </View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <Period
            period={5}
            periodLabel="Quarto extras"
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
            periodLabel="Resultado final"
            period={5}
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

function Protest({ protest }: { protest: Protest }) {
  return (
    <View style={styles.periods}>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>
                Súmula protestada?{' '}
                {protest.state === 'no_protest' ? ' Não' : ' Sim'}
              </Text>
            </View>
            <View style={styles.periods.period.score}>
              <Text>Assinatura</Text>
            </View>
          </View>
        </View>
      </View>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>
                Atleta: {protest.player_name ? protest.player_name : 'N/A'}
              </Text>
            </View>
            <View style={styles.periods.period.score}></View>
          </View>
        </View>
      </View>
    </View>
  );
}

function EndGame({ endDatetime }: { endDatetime: string }) {
  const formattedEndDatetime = new Date(endDatetime).toLocaleTimeString(
    'pt-BR',
    {
      hour: '2-digit',
      minute: '2-digit',
    },
  );
  return (
    <View style={styles.periods}>
      <View style={styles.periods.row}>
        <View style={styles.periods.row.column}>
          <View style={styles.periods.period}>
            <View style={styles.periods.period.quarter}>
              <Text>Fim de jogo às (hh:mm)</Text>
            </View>
            <View style={styles.periods.period.score}>
              <Text>{formattedEndDatetime}</Text>
            </View>
          </View>
        </View>
      </View>
    </View>
  );
}

export interface FibaScoresheetData {
  game_id: string;
  team_a: Team;
  team_b: Team;
  info: Info;
  scorer: Official;
  assistant_scorer: Official;
  timekeeper: Official;
  shot_clock_operator: Official;
  crew_chief: Official;
  umpire_1: Official;
  umpire_2: Official;
  protest: Protest;
}

interface FibaScoresheetProps {
  scoresheetData: FibaScoresheetData;
}

function FibaScoresheet({ scoresheetData }: FibaScoresheetProps) {
  return (
    <Document>
      <Page size="A4" style={styles.page}>
        <View style={styles.title}>
          <Text>{scoresheetData.info.tournament_name}</Text>
        </View>
        <View style={styles.main}>
          <View style={styles.main.header}>
            <HeaderBox
              number={scoresheetData.info.number}
              crewChiefName={scoresheetData.crew_chief.name}
              umpire1Name={scoresheetData.umpire_1.name}
              umpire2Name={scoresheetData.umpire_2.name}
              datetime={scoresheetData.info.actual_start_datetime}
              location={scoresheetData.info.location}
            />
          </View>
          <View style={styles.main.teamsAndRunningScoreContainer}>
            <View
              style={styles.main.teamsAndRunningScoreContainer.containerLeft}
            >
              <TeamBox
                type="A"
                team={scoresheetData.team_a}
                isGameEnded={!!scoresheetData.info.actual_end_datetime}
              />
              <TeamBox
                type="B"
                team={scoresheetData.team_b}
                isGameEnded={!!scoresheetData.info.actual_end_datetime}
              />
              <OfficialsBox
                scorer={scoresheetData.scorer}
                assistantScorer={scoresheetData.assistant_scorer}
                timekeeper={scoresheetData.timekeeper}
                shotClockOperator={scoresheetData.shot_clock_operator}
              />
              <FiscalsBox
                crewChief={scoresheetData.crew_chief}
                umpire1={scoresheetData.umpire_1}
                umpire2={scoresheetData.umpire_2}
              />
            </View>
            <View
              style={styles.main.teamsAndRunningScoreContainer.containerRight}
            >
              <RunningScoreBox
                aTeamRunningScore={scoresheetData.team_a.running_score}
                aTeamLastScore={scoresheetData.team_a.score}
                bTeamRunningScore={scoresheetData.team_b.running_score}
                bTeamLastScore={scoresheetData.team_b.score}
                isGameEnded={!!scoresheetData.info.actual_end_datetime}
              />
              <Periods
                teamA={scoresheetData.team_a}
                teamB={scoresheetData.team_b}
              />
              <EndResults
                teamA={scoresheetData.team_a}
                teamB={scoresheetData.team_b}
              />
              <Protest protest={scoresheetData.protest} />
              <EndGame endDatetime={scoresheetData.info.actual_end_datetime} />
            </View>
          </View>
        </View>
      </Page>
    </Document>
  );
}

export default FibaScoresheet;
