import {
  ProcessingState,
  createProcessingStateManager,
  updateProcessingState,
  resetProcessingState,
} from '../processingState';

describe('processingState', () => {
  describe('createProcessingStateManager', () => {
    it('creates initial state with idle by default', () => {
      const manager = createProcessingStateManager();

      expect(manager.state).toBe('idle');
      expect(manager.error).toBeNull();
      expect(manager.isProcessing).toBe(false);
    });

    it('creates initial state with custom state', () => {
      const manager = createProcessingStateManager('generating');

      expect(manager.state).toBe('generating');
      expect(manager.error).toBeNull();
      expect(manager.isProcessing).toBe(true);
    });
  });

  describe('updateProcessingState', () => {
    it('updates state to generating', () => {
      const currentManager = createProcessingStateManager('idle');
      const updatedManager = updateProcessingState(
        currentManager,
        'generating',
      );

      expect(updatedManager.state).toBe('generating');
      expect(updatedManager.error).toBeNull();
      expect(updatedManager.isProcessing).toBe(true);
    });

    it('updates state to error with error message', () => {
      const currentManager = createProcessingStateManager('generating');
      const errorMessage = 'Something went wrong';
      const updatedManager = updateProcessingState(
        currentManager,
        'error',
        errorMessage,
      );

      expect(updatedManager.state).toBe('error');
      expect(updatedManager.error).toBe(errorMessage);
      expect(updatedManager.isProcessing).toBe(false);
    });

    it('updates state to error with default error message when none provided', () => {
      const currentManager = createProcessingStateManager('generating');
      const updatedManager = updateProcessingState(currentManager, 'error');

      expect(updatedManager.state).toBe('error');
      expect(updatedManager.error).toBe('Unknown error');
      expect(updatedManager.isProcessing).toBe(false);
    });

    it('clears error when updating to non-error state', () => {
      const currentManager = {
        state: 'error' as ProcessingState,
        error: 'Previous error',
        isProcessing: false,
      };
      const updatedManager = updateProcessingState(currentManager, 'idle');

      expect(updatedManager.state).toBe('idle');
      expect(updatedManager.error).toBeNull();
      expect(updatedManager.isProcessing).toBe(false);
    });
  });

  describe('resetProcessingState', () => {
    it('resets to initial idle state', () => {
      const resetManager = resetProcessingState();

      expect(resetManager.state).toBe('idle');
      expect(resetManager.error).toBeNull();
      expect(resetManager.isProcessing).toBe(false);
    });
  });
});
