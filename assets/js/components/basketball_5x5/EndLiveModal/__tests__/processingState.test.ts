import {
  ProcessingState,
  createProcessingStateManager,
  updateProcessingState,
  resetProcessingState,
  PROCESSING_STATES,
} from '../processingState';

describe('processingState', () => {
  describe('createProcessingStateManager', () => {
    it('creates initial state with idle by default', () => {
      const manager = createProcessingStateManager();

      expect(manager.state).toBe(PROCESSING_STATES.IDLE);
      expect(manager.error).toBeNull();
      expect(manager.isProcessing).toBe(false);
    });

    it('creates initial state with custom state', () => {
      const manager = createProcessingStateManager(
        PROCESSING_STATES.GENERATING,
      );

      expect(manager.state).toBe(PROCESSING_STATES.GENERATING);
      expect(manager.error).toBeNull();
      expect(manager.isProcessing).toBe(true);
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

  describe('resetProcessingState', () => {
    it('resets to initial idle state', () => {
      const resetManager = resetProcessingState();

      expect(resetManager.state).toBe(PROCESSING_STATES.IDLE);
      expect(resetManager.error).toBeNull();
      expect(resetManager.isProcessing).toBe(false);
    });
  });
});
