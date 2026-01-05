import { REPORT_SLUGS } from '../../../shared/reportRegistry';

export const PROCESSING_STATES = {
  IDLE: 'idle',
  GENERATING: 'generating',
  ERROR: 'error',
} as const;

export const REPORT_STATUSES = {
  PENDING: 'pending',
  GENERATING: 'generating',
  COMPLETED: 'completed',
  ERROR: 'error',
} as const;

export type ProcessingState =
  (typeof PROCESSING_STATES)[keyof typeof PROCESSING_STATES];

export type ReportStatus =
  (typeof REPORT_STATUSES)[keyof typeof REPORT_STATUSES];

export interface ReportItem {
  id: string;
  translationKey: string;
  status: ReportStatus;
  error?: string;
}

export interface ProcessingStateManager {
  state: ProcessingState;
  error: string | null;
  isProcessing: boolean;
  reports: ReportItem[];
}

export function createProcessingStateManager(
  initialState: ProcessingState = PROCESSING_STATES.IDLE,
): ProcessingStateManager {
  return {
    state: initialState,
    error: null,
    isProcessing: initialState === PROCESSING_STATES.GENERATING,
    reports: [
      {
        id: REPORT_SLUGS.FIBA_SCORESHEET,
        translationKey: 'basketball.reports.fibaScoresheet',
        status: REPORT_STATUSES.PENDING,
      },
      {
        id: REPORT_SLUGS.FIBA_BOXSCORE,
        translationKey: 'basketball.reports.fibaBoxScore.title',
        status: REPORT_STATUSES.PENDING,
      },
    ],
  };
}

export function updateProcessingState(
  currentManager: ProcessingStateManager,
  newState: ProcessingState,
  error?: string,
): ProcessingStateManager {
  return {
    ...currentManager,
    state: newState,
    error:
      newState === PROCESSING_STATES.ERROR ? error || 'Unknown error' : null,
    isProcessing: newState === PROCESSING_STATES.GENERATING,
  };
}

export function updateReportStatus(
  current: ProcessingStateManager,
  reportId: string,
  status: ReportStatus,
  error?: string,
): ProcessingStateManager {
  return {
    ...current,
    reports: current.reports.map((report) =>
      report.id === reportId
        ? {
            ...report,
            status,
            error: status === REPORT_STATUSES.ERROR ? error : undefined,
          }
        : report,
    ),
  };
}

export function resetProcessingState(): ProcessingStateManager {
  return createProcessingStateManager(PROCESSING_STATES.IDLE);
}
