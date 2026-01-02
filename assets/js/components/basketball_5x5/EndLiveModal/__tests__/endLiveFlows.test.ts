import {
  executeBasicEndLive,
  executeMediumEndLive,
  EndLiveCallbacks,
  ReportGenerationCallbacks,
} from '../endLiveFlows';
import { REPORT_SLUGS } from '../../../../shared/reportRegistry';

// Mock the generatorAndUploaders
jest.mock('../../Reports/generatorAndUploaders', () => ({
  fibaScoresheet: jest.fn(),
}));

import generatorAndUploaders from '../../Reports/generatorAndUploaders';

describe('endLiveFlows', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('executeBasicEndLive', () => {
    it('calls pushEvent and onCloseModal with correct parameters', () => {
      const mockCallbacks: EndLiveCallbacks = {
        pushEvent: jest.fn(),
        onCloseModal: jest.fn(),
      };

      executeBasicEndLive(mockCallbacks);

      expect(mockCallbacks.pushEvent).toHaveBeenCalledWith(
        'end-game-live-mode',
        {},
      );
      expect(mockCallbacks.onCloseModal).toHaveBeenCalled();
    });
  });

  describe('executeMediumEndLive', () => {
    const mockCallbacks: ReportGenerationCallbacks = {
      pushEvent: jest.fn(),
      onCloseModal: jest.fn(),
      onProcessingStart: jest.fn(),
      onProcessingComplete: jest.fn(),
      onError: jest.fn(),
    };

    const gameId = 'test-game-id';
    const apiBaseUrl = 'http://test-api.com';

    it('calls onProcessingStart when starting generation', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      mockFibaScoresheet.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks);

      expect(mockCallbacks.onProcessingStart).toHaveBeenCalled();
    });

    it('calls generatorAndUploaders.fibaScoresheet with correct parameters', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      mockFibaScoresheet.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks);

      expect(mockFibaScoresheet).toHaveBeenCalledWith({
        goChampsApiBaseUrl: apiBaseUrl,
        gameId,
        onSuccess: expect.any(Function),
        onError: expect.any(Function),
      });
    });

    it('handles successful report generation', async () => {
      const mockFileReference = {
        publicUrl: 'http://example.com/report.pdf',
        filename: 'report.pdf',
      };

      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      mockFibaScoresheet.mockImplementation(({ onSuccess }) => {
        if (onSuccess) onSuccess(mockFileReference as any);
        return Promise.resolve();
      });

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks);

      expect(mockCallbacks.onProcessingComplete).toHaveBeenCalled();
      expect(mockCallbacks.pushEvent).toHaveBeenCalledWith(
        'end-game-live-mode',
        {
          assets: [
            {
              type: REPORT_SLUGS.FIBA_SCORESHEET,
              url: mockFileReference.publicUrl,
            },
          ],
        },
      );
      expect(mockCallbacks.onCloseModal).toHaveBeenCalled();
    });

    it('handles report generation errors', async () => {
      const mockError = new Error('Generation failed');

      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      mockFibaScoresheet.mockImplementation(({ onError }) => {
        if (onError) onError(mockError);
        return Promise.resolve();
      });

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks);

      expect(mockCallbacks.onError).toHaveBeenCalledWith('Generation failed');
    });

    it('handles unexpected errors', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      mockFibaScoresheet.mockRejectedValue(new Error('Unexpected error'));

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks);

      expect(mockCallbacks.onError).toHaveBeenCalledWith('Unexpected error');
    });

    it('handles non-Error exceptions', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      mockFibaScoresheet.mockRejectedValue('String error');

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks);

      expect(mockCallbacks.onError).toHaveBeenCalledWith(
        'An unexpected error occurred',
      );
    });
  });
});
