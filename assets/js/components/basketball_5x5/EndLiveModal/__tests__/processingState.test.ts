import {
  ProcessingState,
  createProcessingStateManager,
  updateProcessingState,
  updateReportStatus,
  resetProcessingState,
  PROCESSING_STATES,
  REPORT_STATUSES,
} from '../processingState';
import { REPORT_SLUGS } from '../../../../shared/reportRegistry';

describe('processingState', () => {
  describe('createProcessingStateManager', () => {
    it('creates initial state with idle by default', () => {
      const manager = createProcessingStateManager();

      expect(manager.state).toBe(PROCESSING_STATES.IDLE);
      expect(manager.error).toBeNull();
      expect(manager.isProcessing).toBe(false);
      expect(manager.reports).toHaveLength(2);
      expect(manager.reports[0]).toEqual({
        id: REPORT_SLUGS.FIBA_SCORESHEET,
        translationKey: 'basketball.reports.fibaScoresheet.title',
        status: REPORT_STATUSES.PENDING,
      });
      expect(manager.reports[1]).toEqual({
        id: REPORT_SLUGS.FIBA_BOXSCORE,
        translationKey: 'basketball.reports.fibaBoxScore.title',
        status: REPORT_STATUSES.PENDING,
      });
    });

    it('creates initial state with custom state', () => {
      const manager = createProcessingStateManager(
        PROCESSING_STATES.GENERATING,
      );

      expect(manager.state).toBe(PROCESSING_STATES.GENERATING);
      expect(manager.error).toBeNull();
      expect(manager.isProcessing).toBe(true);
      expect(manager.reports).toHaveLength(2);
    });
  });

  describe('updateProcessingState', () => {
    it('updates state to generating', () => {
      const currentManager = createProcessingStateManager(
        PROCESSING_STATES.IDLE,
      );
      const updatedManager = updateProcessingState(
        currentManager,
        PROCESSING_STATES.GENERATING,
      );

      expect(updatedManager.state).toBe(PROCESSING_STATES.GENERATING);
      expect(updatedManager.error).toBeNull();
      expect(updatedManager.isProcessing).toBe(true);
    });

    it('updates state to error with error message', () => {
      const currentManager = createProcessingStateManager(
        PROCESSING_STATES.GENERATING,
      );
      const errorMessage = 'Something went wrong';
      const updatedManager = updateProcessingState(
        currentManager,
        PROCESSING_STATES.ERROR,
        errorMessage,
      );

      expect(updatedManager.state).toBe(PROCESSING_STATES.ERROR);
      expect(updatedManager.error).toBe(errorMessage);
      expect(updatedManager.isProcessing).toBe(false);
    });

    it('updates state to error with default error message when none provided', () => {
      const currentManager = createProcessingStateManager(
        PROCESSING_STATES.GENERATING,
      );
      const updatedManager = updateProcessingState(
        currentManager,
        PROCESSING_STATES.ERROR,
      );

      expect(updatedManager.state).toBe(PROCESSING_STATES.ERROR);
      expect(updatedManager.error).toBe('Unknown error');
      expect(updatedManager.isProcessing).toBe(false);
    });

    it('clears error when updating to non-error state', () => {
      const currentManager = {
        state: PROCESSING_STATES.ERROR as ProcessingState,
        error: 'Previous error',
        isProcessing: false,
        reports: [],
      };
      const updatedManager = updateProcessingState(
        currentManager,
        PROCESSING_STATES.IDLE,
      );

      expect(updatedManager.state).toBe(PROCESSING_STATES.IDLE);
      expect(updatedManager.error).toBeNull();
      expect(updatedManager.isProcessing).toBe(false);
    });
  });

  describe('updateReportStatus', () => {
    it('updates specific report status to completed', () => {
      const currentManager = createProcessingStateManager();
      const updatedManager = updateReportStatus(
        currentManager,
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.COMPLETED,
      );

      expect(updatedManager.reports[0].status).toBe(REPORT_STATUSES.COMPLETED);
      expect(updatedManager.reports[0].error).toBeUndefined();
      expect(updatedManager.reports[1].status).toBe(REPORT_STATUSES.PENDING);
    });

    it('updates specific report status to error with error message', () => {
      const currentManager = createProcessingStateManager();
      const errorMessage = 'Report generation failed';
      const updatedManager = updateReportStatus(
        currentManager,
        REPORT_SLUGS.FIBA_BOXSCORE,
        REPORT_STATUSES.ERROR,
        errorMessage,
      );

      expect(updatedManager.reports[1].status).toBe(REPORT_STATUSES.ERROR);
      expect(updatedManager.reports[1].error).toBe(errorMessage);
      expect(updatedManager.reports[0].status).toBe(REPORT_STATUSES.PENDING);
    });

    it('clears error when updating to non-error status', () => {
      const currentManager = createProcessingStateManager();
      // First set an error
      const managerWithError = updateReportStatus(
        currentManager,
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.ERROR,
        'Some error',
      );

      // Then clear it
      const updatedManager = updateReportStatus(
        managerWithError,
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_STATUSES.COMPLETED,
      );

      expect(updatedManager.reports[0].status).toBe(REPORT_STATUSES.COMPLETED);
      expect(updatedManager.reports[0].error).toBeUndefined();
    });
  });

  describe('resetProcessingState', () => {
    it('resets to initial idle state', () => {
      const resetManager = resetProcessingState();

      expect(resetManager.state).toBe(PROCESSING_STATES.IDLE);
      expect(resetManager.error).toBeNull();
      expect(resetManager.isProcessing).toBe(false);
    });
  });
});
