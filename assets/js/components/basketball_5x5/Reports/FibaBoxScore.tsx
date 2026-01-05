import React from 'react';
import { Document, Page } from '@react-pdf/renderer';
import PageHeader from './Shared/PageHeader';
import GameInfo from './FibaBoxScore/GameInfo';
import TeamBoxScore from './FibaBoxScore/TeamBoxScore';
import ScorePerPeriod from './FibaBoxScore/ScorePerPeriod';
import Legend from './FibaBoxScore/Legend';

export interface Player {
  id: string;
  name: string;
  number: number;
  stats_values: { [stat_name: string]: number };
}

export interface Team {
  name: string;
  points_by_period: { [period: string]: number };
  total_points: number;
  total_player_stats: { [stat_name: string]: number };
  players: Player[];
}

export interface FibaBoxScoreData {
  number: string;
  localtion: string;
  datetime: string;
  actual_start_datetime?: string;
  actual_end_datetime?: string;
  tournament_name: string;
  organization_name: string;
  organization_logo_url: string;
  web_url?: string;
  home_team: Team;
  away_team: Team;
}

interface FibaBoxScoreProps {
  scoreBoxData: FibaBoxScoreData; // Define the appropriate type based on your data structure
}

const styles = {
  page: {
    flexDirection: 'column',
    backgroundColor: '#FFFFFF',
    padding: '12px 12px 20px 12px',
    fontSize: 8,
  },
};

function BoxScorePage({ scoreBoxData }: FibaBoxScoreProps) {
  return (
    <Page style={styles.page}>
      <PageHeader
        organizationName={scoreBoxData.organization_name}
        tournamentName={scoreBoxData.tournament_name}
        organizationLogoUrl={scoreBoxData.organization_logo_url}
        qrCodeUrl={scoreBoxData.web_url}
      />
      <GameInfo
        gameNumber={scoreBoxData.number}
        date={scoreBoxData.datetime.split('T')[0]}
        startTime={scoreBoxData.actual_start_datetime || ''}
        endTime={scoreBoxData.actual_end_datetime || ''}
        venue={scoreBoxData.localtion}
      />
      <TeamBoxScore teamType="home" team={scoreBoxData.home_team} />
      <TeamBoxScore teamType="away" team={scoreBoxData.away_team} />
      <ScorePerPeriod
        homeTeam={scoreBoxData.home_team}
        awayTeam={scoreBoxData.away_team}
      />
      <Legend />
    </Page>
  );
}

function FibaBoxScore({ scoreBoxData }: FibaBoxScoreProps) {
  return (
    <Document title="Fiba BoxScore">
      <BoxScorePage scoreBoxData={scoreBoxData} />
    </Document>
  );
}

export default FibaBoxScore;
