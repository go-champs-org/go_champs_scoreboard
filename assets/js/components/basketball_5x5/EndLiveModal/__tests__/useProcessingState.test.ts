import { renderHook, act } from '@testing-library/react';
import { useProcessingState } from '../useProcessingState';
import { PROCESSING_STATES, REPORT_STATUSES } from '../processingState';
import { REPORT_SLUGS } from '../../../../shared/reportRegistry';

describe('useProcessingState', () => {
  it('initializes with idle state by default', () => {
    const { result } = renderHook(() => useProcessingState());

    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.error).toBeNull();
    expect(result.current.processingManager.isProcessing).toBe(false);
    expect(result.current.processingManager.reports).toHaveLength(1);
    expect(result.current.processingManager.reports[0]).toEqual({
      id: REPORT_SLUGS.FIBA_SCORESHEET,
      translationKey: 'basketball.reports.fibaScoresheet',
      status: REPORT_STATUSES.PENDING,
    });
  });

  it('initializes with custom initial state', () => {
    const { result } = renderHook(() =>
      useProcessingState(PROCESSING_STATES.GENERATING),
    );

    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.GENERATING,
    );
    expect(result.current.processingManager.isProcessing).toBe(true);
  });

  it('starts processing when startProcessing is called', () => {
    const { result } = renderHook(() => useProcessingState());

    act(() => {
      result.current.startProcessing();
    });

    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.GENERATING,
    );
    expect(result.current.processingManager.isProcessing).toBe(true);
    expect(result.current.processingManager.error).toBeNull();
  });

  it('completes processing when completeProcessing is called', () => {
    const { result } = renderHook(() =>
      useProcessingState(PROCESSING_STATES.GENERATING),
    );

    act(() => {
      result.current.completeProcessing();
    });

    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.isProcessing).toBe(false);
    expect(result.current.processingManager.error).toBeNull();
  });

  it('sets error state when setError is called', () => {
    const { result } = renderHook(() => useProcessingState());
    const errorMessage = 'Something went wrong';

    act(() => {
      result.current.setError(errorMessage);
    });

    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.ERROR,
    );
    expect(result.current.processingManager.error).toBe(errorMessage);
    expect(result.current.processingManager.isProcessing).toBe(false);
  });

  it('resets to idle when retry is called', () => {
    const { result } = renderHook(() => useProcessingState());

    // First set an error
    act(() => {
      result.current.setError('Test error');
    });

    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.ERROR,
    );

    // Then retry
    act(() => {
      result.current.retry();
    });

    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.error).toBeNull();
    expect(result.current.processingManager.isProcessing).toBe(false);
  });

  it('resets to initial state when reset is called', () => {
    const { result } = renderHook(() =>
      useProcessingState(PROCESSING_STATES.GENERATING),
    );

    // Change state
    act(() => {
      result.current.setError('Test error');
    });

    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.ERROR,
    );

    // Reset should go back to initial state
    act(() => {
      result.current.reset();
    });

    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.GENERATING,
    );
    expect(result.current.processingManager.isProcessing).toBe(true);
    expect(result.current.processingManager.error).toBeNull();
  });

  it('updates individual report status when updateReportState is called', () => {
    const { result } = renderHook(() => useProcessingState());

    act(() => {
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.GENERATING,
      );
    });

    const fibaReport = result.current.processingManager.reports.find(
      (r) => r.id === REPORT_SLUGS.FIBA_SCORESHEET,
    );
    expect(fibaReport?.status).toBe(REPORT_STATUSES.GENERATING);
  });

  it('updates report status to completed', () => {
    const { result } = renderHook(() => useProcessingState());

    act(() => {
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.COMPLETED,
      );
    });

    const fibaReport = result.current.processingManager.reports.find(
      (r) => r.id === REPORT_SLUGS.FIBA_SCORESHEET,
    );
    expect(fibaReport?.status).toBe(REPORT_STATUSES.COMPLETED);
    expect(fibaReport?.error).toBeUndefined();
  });

  it('updates report status to error with error message', () => {
    const { result } = renderHook(() => useProcessingState());
    const errorMessage = 'Upload failed';

    act(() => {
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.ERROR,
        errorMessage,
      );
    });

    const fibaReport = result.current.processingManager.reports.find(
      (r) => r.id === REPORT_SLUGS.FIBA_SCORESHEET,
    );
    expect(fibaReport?.status).toBe(REPORT_STATUSES.ERROR);
    expect(fibaReport?.error).toBe(errorMessage);
  });

  it('maintains function reference stability including updateReportState', () => {
    const { result, rerender } = renderHook(() => useProcessingState());

    const firstRenderFunctions = {
      startProcessing: result.current.startProcessing,
      completeProcessing: result.current.completeProcessing,
      setError: result.current.setError,
      updateReportState: result.current.updateReportState,
      retry: result.current.retry,
    };

    rerender();

    const secondRenderFunctions = {
      startProcessing: result.current.startProcessing,
      completeProcessing: result.current.completeProcessing,
      setError: result.current.setError,
      updateReportState: result.current.updateReportState,
      retry: result.current.retry,
    };

    expect(firstRenderFunctions.startProcessing).toBe(
      secondRenderFunctions.startProcessing,
    );
    expect(firstRenderFunctions.completeProcessing).toBe(
      secondRenderFunctions.completeProcessing,
    );
    expect(firstRenderFunctions.setError).toBe(secondRenderFunctions.setError);
    expect(firstRenderFunctions.updateReportState).toBe(
      secondRenderFunctions.updateReportState,
    );
    expect(firstRenderFunctions.retry).toBe(secondRenderFunctions.retry);
  });

  it('handles full processing workflow', () => {
    const { result } = renderHook(() => useProcessingState());

    // Initial idle state
    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);

    // Start processing
    act(() => {
      result.current.startProcessing();
    });
    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.GENERATING,
    );
    expect(result.current.processingManager.isProcessing).toBe(true);

    // Complete successfully
    act(() => {
      result.current.completeProcessing();
    });
    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.isProcessing).toBe(false);
  });

  it('handles full report generation workflow', () => {
    const { result } = renderHook(() => useProcessingState());

    // Initial state - reports are pending
    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.reports[0].status).toBe(
      REPORT_STATUSES.PENDING,
    );

    // Start processing - overall state changes, report starts generating
    act(() => {
      result.current.startProcessing();
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.GENERATING,
      );
    });
    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.GENERATING,
    );
    expect(result.current.processingManager.isProcessing).toBe(true);
    expect(result.current.processingManager.reports[0].status).toBe(
      REPORT_STATUSES.GENERATING,
    );

    // Complete report and processing
    act(() => {
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.COMPLETED,
      );
      result.current.completeProcessing();
    });
    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.isProcessing).toBe(false);
    expect(result.current.processingManager.reports[0].status).toBe(
      REPORT_STATUSES.COMPLETED,
    );
  });

  it('handles report error workflow with retry', () => {
    const { result } = renderHook(() => useProcessingState());

    // Start processing
    act(() => {
      result.current.startProcessing();
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.GENERATING,
      );
    });
    expect(result.current.processingManager.isProcessing).toBe(true);
    expect(result.current.processingManager.reports[0].status).toBe(
      REPORT_STATUSES.GENERATING,
    );

    // Report error occurs
    act(() => {
      result.current.updateReportState(
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.ERROR,
        'Network error',
      );
      result.current.setError('Network error');
    });
    expect(result.current.processingManager.state).toBe(
      PROCESSING_STATES.ERROR,
    );
    expect(result.current.processingManager.error).toBe('Network error');
    expect(result.current.processingManager.isProcessing).toBe(false);
    expect(result.current.processingManager.reports[0].status).toBe(
      REPORT_STATUSES.ERROR,
    );
    expect(result.current.processingManager.reports[0].error).toBe(
      'Network error',
    );

    // Retry - should reset both overall state and report status
    act(() => {
      result.current.retry();
    });
    expect(result.current.processingManager.state).toBe(PROCESSING_STATES.IDLE);
    expect(result.current.processingManager.error).toBeNull();
    expect(result.current.processingManager.isProcessing).toBe(false);
    expect(result.current.processingManager.reports[0].status).toBe(
      REPORT_STATUSES.PENDING,
    );
    expect(result.current.processingManager.reports[0].error).toBeUndefined();
  });
});
