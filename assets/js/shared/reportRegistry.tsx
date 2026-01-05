import React from 'react';
import FibaScoresheet, {
  parseFibaScoresheetData,
} from '../components/basketball_5x5/Reports/FibaScoresheet';
import FibaBoxScore from '../components/basketball_5x5/Reports/FibaBoxScore';
import SimpleExample from '../components/shared/Reports/SimpleExample';

export type ReportSlug = 'fiba-scoresheet' | 'fiba-boxscore' | 'simple-example';

export const REPORT_SLUGS: Record<string, ReportSlug> = {
  FIBA_SCORESHEET: 'fiba-scoresheet' as ReportSlug,
  FIBA_BOXSCORE: 'fiba-boxscore' as ReportSlug,
  SIMPLE_EXAMPLE: 'simple-example' as ReportSlug,
};
// Standard props interface that all report components should accept
export interface ReportComponentProps {
  data: any;
}

// Type for report component constructor
export type ReportComponent = React.ComponentType<ReportComponentProps>;

// Configuration for each report type
export interface ReportConfig {
  component: ReportComponent;
  parseData: (rawData: string) => any;
}

// Wrapper components that adapt each report component to the standard interface
export const FibaBoxScoreWrapper: ReportComponent = ({ data }) => (
  <FibaBoxScore scoreBoxData={data} />
);

export const FibaScoresheetWrapper: ReportComponent = ({ data }) => (
  <FibaScoresheet scoresheetData={data} />
);

export const SimpleExampleWrapper: ReportComponent = ({ data }) => (
  <SimpleExample />
);

// Registry of all available reports
export const REPORT_REGISTRY: { [key: string]: ReportConfig } = {
  [REPORT_SLUGS.FIBA_BOXSCORE]: {
    component: FibaBoxScoreWrapper,
    parseData: (rawData: string) => {
      try {
        return JSON.parse(rawData);
      } catch (error) {
        throw new Error(`Invalid JSON data: ${error}`);
      }
    },
  },
  [REPORT_SLUGS.FIBA_SCORESHEET]: {
    component: FibaScoresheetWrapper,
    parseData: parseFibaScoresheetData,
  },
  [REPORT_SLUGS.SIMPLE_EXAMPLE]: {
    component: SimpleExampleWrapper,
    parseData: (rawData: string): null => {
      // SimpleExample doesn't need data, but we still validate the JSON
      try {
        JSON.parse(rawData);
        return null;
      } catch (error) {
        throw new Error(`Invalid JSON data: ${error}`);
      }
    },
  },
};

// Helper to get report config by slug
export function getReportConfig(report_slug: string): ReportConfig | undefined {
  return REPORT_REGISTRY[report_slug];
}
