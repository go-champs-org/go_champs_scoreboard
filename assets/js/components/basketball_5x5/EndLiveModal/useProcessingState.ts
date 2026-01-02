import { useState, useCallback } from 'react';
import {
  ProcessingState,
  createProcessingStateManager,
  updateProcessingState,
  updateReportStatus,
  resetProcessingState,
  ProcessingStateManager,
  ReportStatus,
  PROCESSING_STATES,
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
  initialState: ProcessingState = PROCESSING_STATES.IDLE,
): UseProcessingStateReturn {
  const [processingManager, setProcessingManager] = useState(() =>
    createProcessingStateManager(initialState),
  );

  const startProcessing = useCallback(() => {
    setProcessingManager((current) =>
      updateProcessingState(current, PROCESSING_STATES.GENERATING),
    );
  }, []);

  const completeProcessing = useCallback(() => {
    setProcessingManager((current) =>
      updateProcessingState(current, PROCESSING_STATES.IDLE),
    );
  }, []);

  const setError = useCallback((error: string) => {
    setProcessingManager((current) =>
      updateProcessingState(current, PROCESSING_STATES.ERROR, error),
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
