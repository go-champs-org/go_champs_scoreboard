import { useState, useCallback } from 'react';
import {
  ProcessingState,
  createProcessingStateManager,
  updateProcessingState,
  updateReportStatus,
  resetProcessingState,
  ProcessingStateManager,
  ReportStatus,
} from './processingState';

export interface UseProcessingStateReturn {
  processingManager: ProcessingStateManager;
  startProcessing: () => void;
  completeProcessing: () => void;
  setError: (error: string) => void;
  updateReportState: (
    reportId: string,
    status: ReportStatus,
    error?: string,
  ) => void;
  retry: () => void;
  reset: () => void;
}

export function useProcessingState(
  initialState: ProcessingState = 'idle',
): UseProcessingStateReturn {
  const [processingManager, setProcessingManager] = useState(() =>
    createProcessingStateManager(initialState),
  );

  const startProcessing = useCallback(() => {
    setProcessingManager((current) =>
      updateProcessingState(current, 'generating'),
    );
  }, []);

  const completeProcessing = useCallback(() => {
    setProcessingManager((current) => updateProcessingState(current, 'idle'));
  }, []);

  const setError = useCallback((error: string) => {
    setProcessingManager((current) =>
      updateProcessingState(current, 'error', error),
    );
  }, []);

  const updateReportState = useCallback(
    (reportId: string, status: ReportStatus, error?: string) => {
      setProcessingManager((current) =>
        updateReportStatus(current, reportId, status, error),
      );
    },
    [],
  );

  const retry = useCallback(() => {
    setProcessingManager(resetProcessingState());
  }, []);

  const reset = useCallback(() => {
    setProcessingManager(createProcessingStateManager(initialState));
  }, [initialState]);

  return {
    processingManager,
    startProcessing,
    completeProcessing,
    setError,
    updateReportState,
    retry,
    reset,
  };
}
