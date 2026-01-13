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
  fibaBoxScore: jest.fn(),
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
      onReportComplete: jest.fn(),
      onReportError: jest.fn(),
    };

    const gameId = 'test-game-id';
    const apiBaseUrl = 'http://test-api.com';

    it('calls onProcessingStart when starting generation', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      const mockFibaBoxScore =
        generatorAndUploaders.fibaBoxScore as jest.MockedFunction<
          typeof generatorAndUploaders.fibaBoxScore
        >;
      mockFibaScoresheet.mockImplementation(() => Promise.resolve());
      mockFibaBoxScore.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks, [
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_SLUGS.FIBA_BOXSCORE,
      ]);

      expect(mockCallbacks.onProcessingStart).toHaveBeenCalled();
    });

    it('calls generatorAndUploaders for both reports with correct parameters', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      const mockFibaBoxScore =
        generatorAndUploaders.fibaBoxScore as jest.MockedFunction<
          typeof generatorAndUploaders.fibaBoxScore
        >;
      mockFibaScoresheet.mockImplementation(() => Promise.resolve());
      mockFibaBoxScore.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks, [
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_SLUGS.FIBA_BOXSCORE,
      ]);

      expect(mockFibaScoresheet).toHaveBeenCalledWith({
        goChampsApiBaseUrl: apiBaseUrl,
        gameId,
        onSuccess: expect.any(Function),
        onError: expect.any(Function),
      });

      expect(mockFibaBoxScore).toHaveBeenCalledWith({
        goChampsApiBaseUrl: apiBaseUrl,
        gameId,
        onSuccess: expect.any(Function),
        onError: expect.any(Function),
      });
    });

    it('handles successful generation of both reports', async () => {
      const mockScoresheetFileReference = {
        publicUrl: 'http://example.com/scoresheet.pdf',
        filename: 'scoresheet.pdf',
      };
      const mockBoxScoreFileReference = {
        publicUrl: 'http://example.com/boxscore.pdf',
        filename: 'boxscore.pdf',
      };

      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      const mockFibaBoxScore =
        generatorAndUploaders.fibaBoxScore as jest.MockedFunction<
          typeof generatorAndUploaders.fibaBoxScore
        >;

      mockFibaScoresheet.mockImplementation(({ onSuccess }) => {
        if (onSuccess) onSuccess(mockScoresheetFileReference as any);
        return Promise.resolve();
      });

      mockFibaBoxScore.mockImplementation(({ onSuccess }) => {
        if (onSuccess) onSuccess(mockBoxScoreFileReference as any);
        return Promise.resolve();
      });

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks, [
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_SLUGS.FIBA_BOXSCORE,
      ]);

      expect(mockCallbacks.onReportComplete).toHaveBeenCalledWith(
        REPORT_SLUGS.FIBA_SCORESHEET,
      );
      expect(mockCallbacks.onReportComplete).toHaveBeenCalledWith(
        REPORT_SLUGS.FIBA_BOXSCORE,
      );
      expect(mockCallbacks.onProcessingComplete).toHaveBeenCalled();
      expect(mockCallbacks.pushEvent).toHaveBeenCalledWith(
        'end-game-live-mode',
        {
          assets: [
            {
              type: REPORT_SLUGS.FIBA_SCORESHEET,
              url: mockScoresheetFileReference.publicUrl,
            },
            {
              type: REPORT_SLUGS.FIBA_BOXSCORE,
              url: mockBoxScoreFileReference.publicUrl,
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
      const mockFibaBoxScore =
        generatorAndUploaders.fibaBoxScore as jest.MockedFunction<
          typeof generatorAndUploaders.fibaBoxScore
        >;

      mockFibaScoresheet.mockImplementation(({ onError }) => {
        if (onError) onError(mockError);
        return Promise.resolve();
      });

      mockFibaBoxScore.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks, [
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_SLUGS.FIBA_BOXSCORE,
      ]);

      expect(mockCallbacks.onReportError).toHaveBeenCalledWith(
        REPORT_SLUGS.FIBA_SCORESHEET,
        'Generation failed',
      );
      expect(mockCallbacks.onError).toHaveBeenCalledWith(
        'FIBA Scoresheet: Generation failed',
      );
    });

    it('handles unexpected errors', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      const mockFibaBoxScore =
        generatorAndUploaders.fibaBoxScore as jest.MockedFunction<
          typeof generatorAndUploaders.fibaBoxScore
        >;

      mockFibaScoresheet.mockRejectedValue(new Error('Unexpected error'));
      mockFibaBoxScore.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks, [
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_SLUGS.FIBA_BOXSCORE,
      ]);

      expect(mockCallbacks.onError).toHaveBeenCalledWith(
        'FIBA Scoresheet: Unexpected error',
      );
    });

    it('handles non-Error exceptions', async () => {
      const mockFibaScoresheet =
        generatorAndUploaders.fibaScoresheet as jest.MockedFunction<
          typeof generatorAndUploaders.fibaScoresheet
        >;
      const mockFibaBoxScore =
        generatorAndUploaders.fibaBoxScore as jest.MockedFunction<
          typeof generatorAndUploaders.fibaBoxScore
        >;

      mockFibaScoresheet.mockRejectedValue('String error');
      mockFibaBoxScore.mockImplementation(() => Promise.resolve());

      await executeMediumEndLive(gameId, apiBaseUrl, mockCallbacks, [
        REPORT_SLUGS.FIBA_SCORESHEET,
        REPORT_SLUGS.FIBA_BOXSCORE,
      ]);

      expect(mockCallbacks.onError).toHaveBeenCalledWith(
        'FIBA Scoresheet: String error',
      );
    });
  });
});
