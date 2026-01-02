export type ProcessingState = 'idle' | 'generating' | 'error';

export type ReportStatus = 'pending' | 'generating' | 'completed' | 'error';

export interface ReportItem {
  id: string;
  name: string;
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
  initialState: ProcessingState = 'idle',
): ProcessingStateManager {
  return {
    state: initialState,
    error: null,
    isProcessing: initialState === 'generating',
    reports: [
      {
        id: 'fiba-scoresheet',
        name: 'FIBA Scoresheet',
        translationKey: 'basketball.reports.fibaScoresheet',
        status: 'pending',
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
    error: newState === 'error' ? error || 'Unknown error' : null,
    isProcessing: newState === 'generating',
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
            error: status === 'error' ? error : undefined,
          }
        : report,
    ),
  };
}

export function resetProcessingState(): ProcessingStateManager {
  return createProcessingStateManager('idle');
}
